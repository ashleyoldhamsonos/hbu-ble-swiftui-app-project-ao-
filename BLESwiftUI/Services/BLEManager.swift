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
  @Published var devices = DeviceModel(volumeLevel: 10)
  private var characteristic: CBCharacteristic!
  private var outCharacteristic: CBCharacteristic!
  private var inCharacteristic: CBCharacteristic!
  private var peripheralName: String!
  private var rssi: Int!

  static let shared = BLEManager()

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

    if let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
      peripheralName = name
      rssi = RSSI.intValue
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
    sendPeripheralData()
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
    guard let data = characteristic.value else { return }

    if error != nil {
      print("Error reading characteristic value", error!)
    }
    if characteristic.uuid == Constants.sonosOUTCharacteristic {
      switch data[0] {
      case 2:
        responseMuseFeatureID(characteristic: characteristic)
      case 8:
        parseGattError(characteristic: characteristic)
      default:
        print("Muse Event received")
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

  func setVolumeLevel() {
    print("volume change")
    guard let characteristic = self.inCharacteristic else { return }
    myPeripheral.writeValue(Constants.DukeCommand.setVolumeLevel, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
  }

   private func getGattSettings(characteristic: CBCharacteristic) {
    myPeripheral.writeValue(Constants.DukeCommand.getAncMode, for: inCharacteristic, type: .withoutResponse)
    myPeripheral.writeValue(Constants.DukeCommand.getProductName, for: inCharacteristic, type: .withoutResponse)
    myPeripheral.writeValue(Constants.DukeCommand.getSpatialAudioMode, for: inCharacteristic, type: .withoutResponse)
    myPeripheral.writeValue(Constants.DukeCommand.getVolumeLevel, for: inCharacteristic, type: .withoutResponse)
    myPeripheral.writeValue(Constants.DukeCommand.getBatteryInformation, for: inCharacteristic, type: .withoutResponse)
  }

  private func responseMuseFeatureID(characteristic: CBCharacteristic) {
    guard let data = characteristic.value else { return }

    /// switching on the Muse Feature ID
    switch data[1] {
    case 0: // auxHeadphonesStatus
      parseBatteryStatus(characteristic: characteristic)
    case 1: // auxHeadphonesManagement
      print("deal with headphones management")
    case 2: // auxHeadphonesSettings
      parseHeadphoneSettings(characteristic: characteristic)
    case 3: // auxHeadphonesVolume
      parseHeadphoneVolume(characteristic: characteristic)
    case 4: // auxHeadphonesPlayback
      print("deal with headphones playback")
    case 5: // auxHeadphonesPlaybackMetadata
      print("deal with playback metadata")
    case 6: // auxHeadphonesSoundSwap
      print("deal with sound swap")
    default:
      print("")
    }
  }

  /// getting battery information. I don't quite understand how to convert accurate information here.
  private func parseBatteryStatus(characteristic: CBCharacteristic) {
    guard let data = characteristic.value else { return }

    switch data[2] {
    case 4: // get battery information
      print("Battery", String(data: data[3...], encoding: .utf8) ?? "battery unknown")
    default:
      print("battery default")
    }
  }

  private func parseHeadphoneSettings(characteristic: CBCharacteristic) {
    guard let data = characteristic.value else { return }

    /// PDU specific ID is found on third section of response. Returned as Decimal
    switch data[2] {
    case 9: // get product name
      if let deviceName = String(data: data[4...], encoding: .utf8) {
        devices.name = deviceName
        updateDeviceModel()
      }
    case 14: // get anc mode: Bool
      (data[3] == 0) ? (devices.getANCMode = "Off") : (devices.getANCMode = "On")
    case 18: // get spatial audio: Bool
      (data[3] == 0) ? (devices.getSpatialAudio = "Off") : (devices.getSpatialAudio = "On")
    default:
      print("otherHeadphoneSetting", data[2])
    }
  }

   private func parseHeadphoneVolume(characteristic: CBCharacteristic) {
    guard let data = characteristic.value else { return }

//    print("DATA", data[3])

    /// PDU specific ID is found on third section of response. Returned as Decimal
    switch data[2] {
    case 3: // get volume level
      devices.volumeLevel = Float(truncating: data[3] as NSNumber)
      print("volume", data[3])
    default:
      print("otherHeadphoneVolume", data[2])
    }
  }

  private func parseGattError(characteristic: CBCharacteristic) {
    guard let data = characteristic.value else { return }

    ///payload returns discription of error
    switch data[3] {
    case 1:
      print("Failed namespace not supported")
    case 2:
      print("Failed command not supported")
    case 3:
      print("Failed insufficient resources")
    case 4:
      print("Invalid parameter")
    case 5:
      print("Incorrect state")
    case 6:
      print("Invalid header")
    default:
      print("Invalid length")
    }
  }

  func sendPeripheralData() {
    let data = Peripheral(id: peripherals.count, name: peripheralName, rssi: rssi)
    let newData = ["newPeripheral": data]
    NotificationCenter.default.post(name: .DidSendPeripheralData, object: nil, userInfo: newData)
  }

  func updateDeviceModel() {
    let data = DeviceModel(name: devices.name, volumeLevel: devices.volumeLevel)
    let newData = ["updatedDeviceModel": data]
    NotificationCenter.default.post(name: .DidUpdateDeviceModel, object: nil, userInfo: newData)
  }
}
