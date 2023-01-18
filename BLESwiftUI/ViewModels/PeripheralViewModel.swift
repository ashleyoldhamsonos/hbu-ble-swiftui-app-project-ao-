//
//  PeripheralViewModel.swift
//  BLESwiftUI
//
//  Created by Ashley Oldham on 19/12/2022.
//

import Foundation

class PeripheralViewModel: ObservableObject {

  @Published var peripherals = [Peripheral]()
  var bleManager = BLEManager()

  func addDeviceToArray(device: Peripheral) {
    peripherals.append(device)
  }

  func startScanning() {
    bleManager.startScanning()
  }

  func stopScanning() {
    bleManager.stopScanning()
  }

  func ancOn() {
    bleManager.ancOn()
  }

  func ancOff() {
    bleManager.ancOff()
  }
  
}