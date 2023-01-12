//
//  Constants.swift
//  BLESwiftUI
//
//  Created by Ashley Oldham on 23/12/2022.
//

import Foundation
import CoreBluetooth

struct Constants {
  static let sonosService = CBUUID(string: "FE07")
  static let gattServer = "FDFFAAEAB6B833D7E9"
  static let sonosINCharacteristic = CBUUID(string: "C44F42B1-F5CF-479B-B515-9F1BB0099C98")
  static let sonosOUTCharacteristic = CBUUID(string: "C44F42B1-F5CF-479B-B515-9F1BB0099C99")
  static let batteryLevelService = CBUUID(string: "0x180F")
  static let batteryLevelCharacteristic = CBUUID(string: "0x2A19")

  struct DukeCommand {
    static let getAncMode = Data([0x00, 0x02, 0x0e])
    static let switchAncOn = Data([0x00, 0x02, 0x0f, 0x01])
    static let switchAncOff = Data([0x00, 0x02, 0x0f, 0x00])
    static let play = Data([0x00, 0x04, 0x03, 0x02])
    static let pause = Data([0x00, 0x04, 0x04, 0x01])
    static let getProductName = Data([0x00, 0x02, 0x09])
    static let getSpatialAudioMode = Data([0x00, 0x02, 0x12])
  }

}

