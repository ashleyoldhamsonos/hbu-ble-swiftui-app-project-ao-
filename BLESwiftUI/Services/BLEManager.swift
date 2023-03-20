//
//  BLEManager.swift
//  BLESwiftUI
//
//  Created by Ashley Oldham on 13/12/2022.
//

import Foundation
import CoreBluetooth

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {

  private var centralManager: CBCentralManager!
  @Published var isBluetoothOn = false
  @Published var isConnected = false
  private var peripherals = [Peripheral]()
  private var connectedPeripheral: CBPeripheral!
  private var device = DeviceModel()
  private var characteristic: CBCharacteristic!
  private var outCharacteristic: CBCharacteristic!
  private var inCharacteristic: CBCharacteristic!
  private var peripheralName: String!
  private var rssi: Int!

  static let shared = BLEManager()

  override init() {
    super .init()
    centralManager = CBCentralManager(delegate: self, queue: nil)
  }

  // MARK: Central Manager methods

  ///method must be implemented before we scan and is called whenever there is a change with Bluetooth state
  func centralManagerDidUpdateState(_ central: CBCentralManager) {

    switch central.state {
    case .poweredOn:
      print("Is powered on")
      isBluetoothOn = true
//      updateBleStatus(status: true)
      startScanning()
    case .poweredOff:
      print("Is powered off")
      isBluetoothOn = false
    case .unsupported:
      print("Is unsupported")
    case .unauthorized:
      print("Is unauthorised. User denies Bluetooth app access")
    case .unknown:
      print("Is unknown")
    case .resetting:
      print("Resetting")
    @unknown default:
      print("Error")
    }
  }

  /// method returns devices that advertise the sonos service as requested within the startScanning method
  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

    if let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
      peripheralName = name
      rssi = RSSI.intValue
    } else {
      peripheralName = "Unknown"
    }

//    if peripheralName == Constants.gattServer {
//      myPeripheral = peripheral
//      myPeripheral.delegate = self
//      central.connect(myPeripheral)
//      stopScanning()
//    }
    connectedPeripheral = peripheral

//    let advertisementData = advertisementData.description
    let newPeripheral = Peripheral(id: peripherals.count, name: peripheralName, peripheral: connectedPeripheral, rssi: RSSI.intValue)
    print(newPeripheral.name)
    peripherals.append(newPeripheral)
    sendPeripheralData()
  }

  /// gets called on successful connection to peripheral
  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    print("Connected", connectedPeripheral)
    stopScanning()
    connectedPeripheral.discoverServices([Constants.sonosService])
  }

  func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    device = DeviceModel()
    print("Disconnected", connectedPeripheral)
  }

  // MARK: Peripheral methods

  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    guard let services = peripheral.services else { return }

    if error != nil {
      print("Error reading services")
    } else {
      for service in services {
        if service.uuid == Constants.sonosService {
          connectedPeripheral.discoverCharacteristics([Constants.sonosINCharacteristic, Constants.sonosOUTCharacteristic], for: service)
        } else {
          connectedPeripheral.discoverCharacteristics(nil, for: service)
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
        connectedPeripheral.setNotifyValue(true, for: outCharacteristic)
        connectedPeripheral.readValue(for: outCharacteristic)

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

  func disconnectDevice() {
    centralManager.cancelPeripheralConnection(connectedPeripheral)
//    device = DeviceModel()
    resetDeviceModel()
  }

  /// Use one function for writing all values to peripheral ?
  func writeData(data: Data) {
    print("\(data)")
    guard let characteristic = self.inCharacteristic else { return }
    connectedPeripheral.writeValue(data, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
  }

  func ancOn() {
    print("anc ON")
    guard let characteristic = self.inCharacteristic else { return }
    connectedPeripheral.writeValue(Data([AuxDevicePdu.command.rawValue, AuxHeadphones_NamespaceId.auxHeadphonesSettings.rawValue, AuxHeadphonesSettings_PduId.setAncMode.rawValue, AuxHeadphonesCommand_Anc.ancOn.rawValue]), for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
  }

  func ancOff() {
    print("anc OFF")
    guard let characteristic = self.inCharacteristic else { return }
    connectedPeripheral.writeValue(Data([AuxDevicePdu.command.rawValue, AuxHeadphones_NamespaceId.auxHeadphonesSettings.rawValue, AuxHeadphonesSettings_PduId.setAncMode.rawValue, AuxHeadphonesCommand_Anc.ancOff.rawValue]), for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
  }

  func playCommand() {
    print("play")
    guard let characteristic = self.inCharacteristic else { return }
    connectedPeripheral.writeValue(Constants.DukeCommand.play, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
  }

  func pauseCommand() {
    print("pause")
    guard let characteristic = self.inCharacteristic else { return }
    connectedPeripheral.writeValue(Constants.DukeCommand.pause, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
  }

  func skipToNextTrack() {
    print("next track")
    guard let characteristic = self.inCharacteristic else { return }
    connectedPeripheral.writeValue(Constants.DukeCommand.skipToNextTrack, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
  }

  func skipToPreviousTrack() {
    print("previous track")
    guard let characteristic = self.inCharacteristic else { return }
    connectedPeripheral.writeValue(Constants.DukeCommand.skipToPreviousTrack, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
  }

  func spatialAudioOn() {
    print("spatial on")
    guard let characteristic = self.inCharacteristic else { return }
    connectedPeripheral.writeValue(Constants.DukeCommand.spatialAudioModeOn, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
  }

  func spatialAudioOff() {
    print("spatial off")
    guard let characteristic = self.inCharacteristic else { return }
    connectedPeripheral.writeValue(Constants.DukeCommand.spatialAudioModeOff, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
  }

  func setMaxVolumeLevel(value: Float) {
    print("volume change")
    let uIntValue = UInt8(Int(value))
    guard let characteristic = self.inCharacteristic else { return }
    connectedPeripheral.writeValue(Data([0x00, 0x02, 0x1c, uIntValue]), for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
  }

  /// function called when connected to Peripheral. Recieves data to update DeviceModel
   private func getGattSettings(characteristic: CBCharacteristic) {
    connectedPeripheral.writeValue(Constants.DukeCommand.getAncMode, for: inCharacteristic, type: .withoutResponse)
    connectedPeripheral.writeValue(Constants.DukeCommand.getProductName, for: inCharacteristic, type: .withoutResponse)
    connectedPeripheral.writeValue(Constants.DukeCommand.getSpatialAudioMode, for: inCharacteristic, type: .withoutResponse)
    connectedPeripheral.writeValue(Constants.DukeCommand.getMaxVolumeLevel, for: inCharacteristic, type: .withoutResponse)
    connectedPeripheral.writeValue(Constants.DukeCommand.getBatteryInformation, for: inCharacteristic, type: .withoutResponse)
    connectedPeripheral.writeValue(Constants.DukeCommand.getPlaybackStatus, for: inCharacteristic, type: .withoutResponse)

     /// used to check maximum mtu length allowed with connected device
//    connectedPeripheral.maximumWriteValueLength(for: .withoutResponse)
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
      parseHeadphonePlayback(characteristic: characteristic)
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

//    print("DATA", data[3])
    /// PDU specific ID is found on third section of response. Returned as Decimal
    switch data[2] {
    case 9: // get product name
      if let deviceName = String(data: data[4...], encoding: .utf8) {
        device.name = deviceName
        updateDeviceModel()
      }
    case 14: // get anc mode: Bool
      (data[3] == 0) ? (device.getANCMode = false) : (device.getANCMode = true)
      updateDeviceModel()
    case 18: // get spatial audio: Bool
      (data[3] == 0) ? (device.getSpatialAudio = false) : (device.getSpatialAudio = true)
      updateDeviceModel()
    case 27: // get max volume
      device.volumeLevel = Float(data[3])
      updateDeviceModel()
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
      device.volumeLevel = Float(truncating: data[3] as NSNumber)
      print("volume", data[3])
    default:
      print("otherHeadphoneVolume", data[2])
    }
  }

  private func parseHeadphonePlayback(characteristic: CBCharacteristic) {
    guard let data = characteristic.value else { return }
    switch data[2] {
    case 7: // get isPlaying Boolean
      (data[3] == 0) ? (device.isPlaying = false) : (device.isPlaying = true)
      updateDeviceModel()
    default:
      break
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

  // MARK: NotificationCenter

  func sendPeripheralData() {
    let data = Peripheral(id: peripherals.count, name: peripheralName, peripheral: connectedPeripheral, rssi: rssi)
    let newData = ["newPeripheral": data]
    NotificationCenter.default.post(name: .DidSendPeripheralData, object: nil, userInfo: newData)
  }

  func updateDeviceModel() {
    let data = DeviceModel(name: device.name, getANCMode: device.getANCMode, getSpatialAudio: device.getSpatialAudio, volumeLevel: device.volumeLevel, isPlaying: device.isPlaying)
    let newData = ["updatedDeviceModel": data]
    NotificationCenter.default.post(name: .DidUpdateDeviceModel, object: nil, userInfo: newData)
  }

  func resetDeviceModel() {
    let data = DeviceModel()
    let newData = ["resetDeviceModel": data]
    NotificationCenter.default.post(name: .DidResetDeviceModel, object: nil, userInfo: newData)
  }

  func updateBleStatus(status: Bool) {
    let data = status
    let newData = ["updateBleStatus": data]
    NotificationCenter.default.post(name: .DidUpdateBleStatus, object: nil, userInfo: newData)
  }

  func connect(device: CBPeripheral) {
    centralManager.connect(device)
    connectedPeripheral = device
    connectedPeripheral.delegate = self
    print("CONNECTING TO \(device)")
  }
}
