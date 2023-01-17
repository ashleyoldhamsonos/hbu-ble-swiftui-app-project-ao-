//
//  Peripheral.swift
//  BLESwiftUI
//
//  Created by Ashley Oldham on 13/12/2022.
//

import Foundation

struct Peripheral: Identifiable {
  let id: Int
  let name: String
  let rssi: Int
  var icon: String {
    return getIconName(name)
  }
//  let advertisingData: String

  func getIconName(_ peripheralName: String) -> String {
    switch peripheralName {
    case Constants.gattServer:
      return "headphones.circle"
    default:
      return "hifispeaker"
    }
  }
}
