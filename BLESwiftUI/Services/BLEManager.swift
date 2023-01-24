//
//  BLEManager.swift
//  BLESwiftUI
//
//  Created by Ashley Oldham on 13/12/2022.
//

import Foundation
import CoreBluetooth
import SwiftUI

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {

  private var centralManager: CBCentralManager!
  private var myPeripheral: CBPeripheral!
  @Published var isBluetoothOn = false
//  @Published var peripherals = [Peripheral]()
//  @Published var devices = DeviceModel()
  private var characteristic: CBCharacteristic!
  private var outCharacteristic: CBCharacteristic!
  private var inCharacteristic: CBCharacteristic!

  override init() {
    super .init()
    centralManager = CBCentralManager(delegate: self, queue: nil)
//    centralManager.delegate = self
  }

  // MARK: Central Manager methods

  func centralManagerDidUpdateState(_ central: CBCentralManager) {

    switch central.state {
    case .poweredOn:
      print("Is powered on")
      isBluetoothOn = true
      centralManager.scanForPeripherals(withServices: [Constants.sonosService])
    case .poweredOff:
      print("Is powered off")
      isBluetoothOn = false
    case .unsupported:
      print("Is unsupported")
    case .unauthorized:
      print("Is unauthorised")
    case .unknown:
      print("Is unknown")
    case .resetting:
      print("Resetting")
    @unknown default:
      print("Error")
    }
  }

  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    var peripheralName: String!

    if let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
      peripheralName = name
    } else {
      peripheralName = "Unknown"
    }

    if peripheralName == Constants.gattServer {
      myPeripheral = peripheral
      myPeripheral.delegate = self
      central.connect(myPeripheral)
      stopScanning()
    }

//    let advertisementData = advertisementData.description
    let newPeripheral = Peripheral(id: PeripheralViewModel.shared.peripherals.count, name: peripheralName, rssi: RSSI.intValue)
//    print(newPeripheral.name)
//    peripherals.append(newPeripheral)
    PeripheralViewModel.shared.addDeviceToArray(device: newPeripheral)
  }

  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//    myPeripheral.discoverServices([CBUUID(string: "0x180F")]) //battery service
    myPeripheral.discoverServices([Constants.sonosService])
  }

  // MARK: Peripheral methods

  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    guard let services = peripheral.services else { return }

    if error != nil {
      print("Error reading services")
    } else {
      for service in services {
        if service.uuid == Constants.sonosService {
          myPeripheral.discoverCharacteristics([Constants.sonosINCharacteristic, Constants.sonosOUTCharacteristic], for: service)
        } else {
          myPeripheral.discoverCharacteristics(nil, for: service)
        }
      }
//      print("Discovered services: \(services)")
    }
  }

  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    guard let characteristics = service.characteristics else { return }

    var foundOutCharacteristic = false
    var foundInCharacteristic = false

//    print("Found \(characteristics.count) characteristics")

    for characteristic in characteristics {

      if characteristic.uuid == Constants.sonosOUTCharacteristic {
        outCharacteristic = characteristic
        myPeripheral.setNotifyValue(true, for: outCharacteristic)
        myPeripheral.readValue(for: outCharacteristic)

        foundOutCharacteristic = true
      }

      if characteristic.uuid == Constants.sonosINCharacteristic {
        inCharacteristic = characteristic
        getGattSettings(characteristic: inCharacteristic)

        foundInCharacteristic = true
      }
    }

    if !foundInCharacteristic || !foundOutCharacteristic {
      print("Error finding Gatt Characteristics")
    }
  }

  /// decodes data once triggered with change of OUTCharacterisitc
  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {

    if error != nil {
      print("Error reading characteristic value", error!)
    }
    if characteristic.uuid == Constants.sonosOUTCharacteristic {
      parseGattCharacteristic(characteristic: characteristic)
    }
  }

  func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
    if error != nil {
      print(error!)
    } else {
      print("Will receive notifications")
    }
  }

  // MARK: Class functions

  func startScanning() {
    PeripheralViewModel.shared.peripherals = []
    centralManager.scanForPeripherals(withServices: [Constants.sonosService])
  }

  func stopScanning() {
    centralManager.stopScan()
  }

  func ancOn() {
    print("anc ON")
    guard let characteristic = self.inCharacteristic else { return }
    myPeripheral.writeValue(Constants.DukeCommand.switchAncOn, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
  }

  func ancOff() {
    print("anc OFF")
    guard let characteristic = self.inCharacteristic else { return }
    myPeripheral.writeValue(Constants.DukeCommand.switchAncOff, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
  }

  func playCommand() {
    print("play")
    guard let characteristic = self.inCharacteristic else { return }
    myPeripheral.writeValue(Constants.DukeCommand.play, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
  }

  func pauseCommand() {
    print("pause")
    guard let characteristic = self.inCharacteristic else { return }
    myPeripheral.writeValue(Constants.DukeCommand.pause, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
  }

  func skipToNextTrack() {
    print("next track")
    guard let characteristic = self.inCharacteristic else { return }
    myPeripheral.writeValue(Constants.DukeCommand.skipToNextTrack, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
  }

  func skipToPreviousTrack() {
    print("previous track")
    guard let characteristic = self.inCharacteristic else { return }
    myPeripheral.writeValue(Constants.DukeCommand.skipToPreviousTrack, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
  }

  func spatialAudioOn() {
    print("spatial on")
    guard let characteristic = self.inCharacteristic else { return }
    myPeripheral.writeValue(Constants.DukeCommand.spatialAudioModeOn, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
  }

  func spatialAudioOff() {
    print("spatial off")
    guard let characteristic = self.inCharacteristic else { return }
    myPeripheral.writeValue(Constants.DukeCommand.spatialAudioModeOff, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
  }

   private func getGattSettings(characteristic: CBCharacteristic) {
    myPeripheral.writeValue(Constants.DukeCommand.getAncMode, for: inCharacteristic, type: .withoutResponse)
    myPeripheral.writeValue(Constants.DukeCommand.getProductName, for: inCharacteristic, type: .withoutResponse)
    myPeripheral.writeValue(Constants.DukeCommand.getSpatialAudioMode, for: inCharacteristic, type: .withoutResponse)
//    myPeripheral.writeValue(Constants.DukeCommand.getBatteryInformation, for: inCharacteristic, type: .withoutResponse)
  }

   private func parseGattCharacteristic(characteristic: CBCharacteristic) {
    guard let data = characteristic.value else { return }

//    print("DATA", data[3])

    switch data[2] {
    case 9: // get product name
      PeripheralViewModel.shared.devices.name = String(data: data[4...], encoding: .utf8) ?? "unknown"
    case 14: // get anc mode: Bool
      (data[3] == 0) ? (PeripheralViewModel.shared.devices.getANCMode = "Off") : (PeripheralViewModel.shared.devices.getANCMode = "On")
    case 18: // get spatial audio: Bool
      (data[3] == 0) ? (PeripheralViewModel.shared.devices.getSpatialAudio = "Off") : (PeripheralViewModel.shared.devices.getSpatialAudio = "On")
//    case 4: // get battery information
//      print("BAT", String(data: data[4...], encoding: .utf8) ?? "battery unknown")
    default:
      print("default")
    }
  }
}
