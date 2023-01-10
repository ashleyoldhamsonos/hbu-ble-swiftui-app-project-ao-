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

  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    guard let services = peripheral.services else { return }

    if error != nil {
      print("Error reading services")
    } else {
      for service in services {
//        print("SERVICE", service)
          myPeripheral.discoverCharacteristics(nil, for: service)
      }
      print("Discovered services: \(services)")
    }
  }

  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    guard let characteristics = service.characteristics else { return }

    var foundOutCharacteristic = false
    var foundInCharacteristic = false

    print("Found \(characteristics.count) characteristics")

    for characteristic in characteristics {
      if characteristic.uuid.uuidString == Constants.sonosOUTCharacteristic {
        outCharacteristic = characteristic
        myPeripheral.setNotifyValue(true, for: outCharacteristic)
        myPeripheral.readValue(for: outCharacteristic)
        foundOutCharacteristic = true

        print("read Characteristic: \(outCharacteristic.uuid)")
      }

      if characteristic.uuid.uuidString == Constants.sonosINCharacteristic {
        inCharacteristic = characteristic
        print("write Characteristic: \(inCharacteristic.uuid)")
        foundInCharacteristic = true
//        self.characteristic = characteristic
      }
    }

    if !foundInCharacteristic || !foundOutCharacteristic {
      print("Error finding Gatt Characteristics")
    }
  }

  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    guard let data = characteristic.value else { return }

    if error != nil {
      print("didUpdateValeFor", error!)
    }
    if characteristic.uuid.uuidString == Constants.sonosOUTCharacteristic {
      print("VALUE", data[0])
    }
  }

  func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
    if error != nil {
      print(error!)
    }
  }

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
    myPeripheral.writeValue(Constants.switchAncOn, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
  }

  func ancOff() {
    print("anc OFF")
    guard let characteristic = self.inCharacteristic else { return }
    myPeripheral.writeValue(Constants.switchAncOff, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
  }

  func playCommand() {
    guard let characteristic = self.inCharacteristic else { return }
    myPeripheral.writeValue(Constants.play, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
  }

  func pauseCommand() {
    guard let characteristic = self.inCharacteristic else { return }
    myPeripheral.writeValue(Constants.pause, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
  }

}
