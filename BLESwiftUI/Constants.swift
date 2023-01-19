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
    static let play = Data([0x00, 0x04, 0x03])
    static let pause = Data([0x00, 0x04, 0x04])
    static let skipToNextTrack = Data([0x00, 0x04, 0x06])
    static let skipToPreviousTrack = Data([0x00, 0x04, 0x05])
    static let getProductName = Data([0x00, 0x02, 0x09])
    static let getSpatialAudioMode = Data([0x00, 0x02, 0x12])
    static let spatialAudioModeOn = Data([0x00, 0x02, 0x13, 0x01])
    static let spatialAudioModeOff = Data([0x00, 0x02, 0x13, 0x00])
    static let getBatteryInformation = Data([0x00, 0x00, 0x04])
  }

  struct PlaybackControlButton {
    static let playImage = "play.circle"
    static let pauseImage = "pause.circle"
    static let nextTrackImage = "forward.end"
    static let previousTrackImage = "backward.end"
    static let playPauseWidth: CGFloat = 70
    static let playPauseHeight: CGFloat = 70
    static let skipNextTrackWidth: CGFloat = 20
    static let skipNextTrackHeight: CGFloat = 20
    static let skipPreviousTrackWidth: CGFloat = 20
    static let skipPreviousTrackHeight: CGFloat = 20
  }

}

