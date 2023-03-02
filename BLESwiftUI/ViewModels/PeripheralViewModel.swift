//
//  PeripheralViewModel.swift
//  BLESwiftUI
//
//  Created by Ashley Oldham on 19/12/2022.
//

import UIKit
import SwiftUI
import CoreBluetooth

class PeripheralViewModel: ObservableObject {

  @Published var peripherals = [Peripheral]()
  @Published var device = DeviceModel()
  @Published var isConnected = false

  init() {
    createObservers()
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  private func createObservers() {
    NotificationCenter.default.addObserver(self, selector: #selector(didGetPeripheralData(_:)), name: Notification.Name.DidSendPeripheralData, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(didUpdateDeviceModel(_:)), name: Notification.Name.DidUpdateDeviceModel, object: nil)
  }

  @objc func didGetPeripheralData(_ notification: Notification) {
    guard let newPeripheralData = notification.userInfo?["newPeripheral"] as? Peripheral else { return }

    peripherals.append(newPeripheralData)
  }

  @objc func didUpdateDeviceModel(_ notification: Notification) {
    guard let newModelData = notification.userInfo?["updatedDeviceModel"] as? DeviceModel else { return }

    device = newModelData
  }

  @objc func didResetDeviceModel(_ notification: Notification) {
    guard let newModelData = notification.userInfo?["resetDeviceModel"] as? DeviceModel else { return }

    device = newModelData
  }

  func startScanning() {
    peripherals = []
    BLEManager.shared.startScanning()
  }

  func stopScanning() {
    BLEManager.shared.stopScanning()
  }

  func ancOn() {
    BLEManager.shared.ancOn()
  }

  func ancOff() {
    BLEManager.shared.ancOff()
  }

  func spatialAudioOn() {
    BLEManager.shared.spatialAudioOn()
  }

  func spatialAudioOff() {
    BLEManager.shared.spatialAudioOff()
  }

  func playCommand() {
    BLEManager.shared.playCommand()
  }

  func pauseCommand() {
    BLEManager.shared.pauseCommand()
  }

  func skipToPreviousTrack() {
    BLEManager.shared.skipToPreviousTrack()
  }

  func skipToNextTrack() {
    BLEManager.shared.skipToNextTrack()
  }

  func setMaxVolumeLevel(value: Float) {
    BLEManager.shared.setMaxVolumeLevel(value: value)
  }

  func connect(device: CBPeripheral) {
    isConnected = true
    BLEManager.shared.connect(device: device)
  }

  func disconnectDevice() {
    isConnected = false
    BLEManager.shared.disconnectDevice()
    NotificationCenter.default.addObserver(self, selector: #selector(didResetDeviceModel(_:)), name: Notification.Name.DidResetDeviceModel, object: nil)
//    device = DeviceModel()
  }

  func hapticFeedback() {
    let haptic = UINotificationFeedbackGenerator()
    haptic.notificationOccurred(.success)
  }
  
}
