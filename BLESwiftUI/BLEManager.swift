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
  let gattServer = "FDFFAAEAB6B833D7E9"
//  @ObservedObject var peripheralViewModel: PeripheralViewModel

  override init() {
    super .init()
    centralManager = CBCentralManager(delegate: self, queue: nil)
    centralManager.delegate = self
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

    if peripheralName == "FDFFAAEAB6B833D7E9" {
      myPeripheral = peripheral
      myPeripheral.delegate = self
      central.connect(myPeripheral)
    }

    let advertisementData = advertisementData.description
    let newPeripheral = Peripheral(id: peripherals.count, name: peripheralName, rssi: RSSI.intValue, advertisingData: advertisementData)
    print(newPeripheral.name)
    peripherals.append(newPeripheral)
  }

  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//    myPeripheral.discoverServices([CBUUID(string: "0x180F")]) //battery service
    myPeripheral.discoverServices([CBUUID(string: "FE07")])
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
      if characteristic.uuid.uuidString == "C44F42B1-F5CF-479B-B515-9F1BB0099C99" {
        peripheral.readValue(for: characteristic)
        peripheral.setNotifyValue(true, for: characteristic)
      }
      if characteristic.uuid.uuidString == "C44F42B1-F5CF-479B-B515-9F1BB0099C98" {
//        let string = "0x00020f01"
//        let data = string.data(using: String.Encoding(rawValue: NSUTF8StringEncoding))!
        let ancOn = Data([0x00, 0x02, 0x0f, 0x01])
        peripheral.writeValue(ancOn, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
      }
    }
  }

  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    guard let char = characteristic.value else { return }

    if characteristic.uuid.uuidString == "C44F42B1-F5CF-479B-B515-9F1BB0099C99" {
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
  }

  func ancOff() {
    print("anc OFF")
  }

}
