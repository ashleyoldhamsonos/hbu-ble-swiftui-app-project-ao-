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

  var centralManager: CBCentralManager!
  var myPeripheral: CBPeripheral!
  @Published var isBluetoothOn = false
  @Published var peripherals = [Peripheral]()
  private let sonosService = CBUUID(string: "FE07")
  private let switchAncOn = Data([0x00, 0x02, 0x0f, 0x01])
  private let switchAncOff = Data([0x00, 0x02, 0x0f, 0x00])
  private let play = Data([0x00, 0x04, 0x03, 0x02])
  private let pause = Data([0x00, 0x04, 0x04, 0x01])
  private let getProductName = Data([0x00, 0x02, 0x09])
  let batteryLevelService = CBUUID(string: "0x180F")
  let batteryLevelCharacteristic = CBUUID(string: "0x2A19")
  var characteristic: CBCharacteristic!

  override init() {
    super .init()
    centralManager = CBCentralManager(delegate: self, queue: nil)
//    centralManager.delegate = self
  }

  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    if central.state == .poweredOn {
      isBluetoothOn = true
    } else {
      isBluetoothOn = false
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
    }

//    let advertisementData = advertisementData.description
    let newPeripheral = Peripheral(id: peripherals.count, name: peripheralName, rssi: RSSI.intValue)
    print(newPeripheral.name)
    peripherals.append(newPeripheral)
  }

  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//    myPeripheral.discoverServices([CBUUID(string: "0x180F")]) //battery service
    myPeripheral.discoverServices([sonosService])
  }

  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    guard let services = peripheral.services else { return }

    if error != nil {
      print("Error reading services")
    } else {
      for service in services {
        myPeripheral.discoverCharacteristics(nil, for: service)
      }
    }
  }

  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    guard let characteristics = service.characteristics else { return }

    for characteristic in characteristics {

      if characteristic.uuid.uuidString == Constants.sonosReadCharacteristic {
        peripheral.readValue(for: characteristic)
        print("WWW", characteristic.properties)
      }

      if characteristic.uuid.uuidString == Constants.sonosWriteCharacteristic {
        self.characteristic = characteristic
      }
    }
  }

  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    guard let char = characteristic.value else { return }

    if characteristic.uuid.uuidString == Constants.sonosReadCharacteristic {
      peripheral.setNotifyValue(true, for: characteristic)
      print("AAA", char.first as Any)
    }
  }

  func startScanning() {
    centralManager.scanForPeripherals(withServices: nil)
  }

  func stopScanning() {
    centralManager.stopScan()
  }

  func ancOn() {
    print("anc ON")
    guard let characteristic = self.characteristic else { return }
    myPeripheral.writeValue(switchAncOn, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
  }

  func ancOff() {
    print("anc OFF")
    guard let characteristic = self.characteristic else { return }
    myPeripheral.writeValue(switchAncOff, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
  }

  func playCommand() {
    guard let characteristic = self.characteristic else { return }
    myPeripheral.writeValue(play, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
  }

  func pauseCommand() {
    guard let characteristic = self.characteristic else { return }
    myPeripheral.writeValue(pause, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
  }


}
