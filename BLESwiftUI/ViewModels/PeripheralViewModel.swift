//
//  PeripheralViewModel.swift
//  BLESwiftUI
//
//  Created by Ashley Oldham on 19/12/2022.
//

import UIKit

class PeripheralViewModel: ObservableObject {

  @Published var peripherals = [Peripheral]()
  @Published var devices = DeviceModel()
  var bleManager = BLEManager()

  static let shared = PeripheralViewModel()

  func addDeviceToArray(device: Peripheral) {
    print(device.name)
    for item in peripherals {
      if item.name == device.name { return }
    }
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

  func spatialAudioOn() {
    bleManager.spatialAudioOn()
  }

  func spatialAudioOff() {
    bleManager.spatialAudioOff()
  }

  func playCommand() {
    bleManager.playCommand()
  }

  func pauseCommand() {
    bleManager.pauseCommand()
  }

  func skipToPreviousTrack() {
    bleManager.skipToPreviousTrack()
  }

  func skipToNextTrack() {
    bleManager.skipToNextTrack()
  }
  
}
