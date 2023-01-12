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
  @Published var peripherals = [Peripheral]()
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
//    if central.state == .poweredOn {
//      isBluetoothOn = true
//      centralManager.scanForPeripherals(withServices: [Constants.sonosService])
//    } else {
//      isBluetoothOn = false
//    }

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
    let newPeripheral = Peripheral(id: peripherals.count, name: peripheralName, rssi: RSSI.intValue)
    print(newPeripheral.name)
    peripherals.append(newPeripheral)
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
      print("Discovered services: \(services)")
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
    guard let data = characteristic.value, let byte = data.first else { return }

    if error != nil {
      print("Error reading characteristic value", error!)
    }
    if characteristic.uuid == Constants.sonosOUTCharacteristic {
//      print("VALUE", data[3])
      switch byte {
      case 0:
        print("0th bit")
      case 1:
        print("1st bit")
      case 2:
        print(String(data: data, encoding: .utf8) as Any)
      case 3:
        print("3rd bit")
      case 4:
        print("4th bit")
      case 5:
        print("5th bit")
      case 6:
        print("6th bit")
      default:
        print("Other")
      }

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
    peripherals = []
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
    guard let characteristic = self.inCharacteristic else { return }
    myPeripheral.writeValue(Constants.DukeCommand.play, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
  }

  func pauseCommand() {
    guard let characteristic = self.inCharacteristic else { return }
    myPeripheral.writeValue(Constants.DukeCommand.pause, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
  }

  func getGattSettings(characteristic: CBCharacteristic) {
//    myPeripheral.writeValue(Constants.DukeCommand.getAncMode, for: inCharacteristic, type: .withoutResponse)
    myPeripheral.writeValue(Constants.DukeCommand.getProductName, for: inCharacteristic, type: .withoutResponse)
//    myPeripheral.writeValue(Constants.DukeCommand.getSpatialAudioMode, for: inCharacteristic, type: .withoutResponse)
  }

}
