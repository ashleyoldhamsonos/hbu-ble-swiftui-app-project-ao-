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
  let advertisingData: String
}
