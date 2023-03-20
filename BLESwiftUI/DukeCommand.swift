//
//  DukeCommand.swift
//  BLESwiftUI
//
//  Created by Ashley Oldham on 10/03/2023.
//

import Foundation

// Duke PDU Type

enum AuxDevicePdu: UInt8, Codable {
  case command = 0x00
  case event = 0x01
  case response = 0x02
  case error = 0x80
}

// Duke Error Code

enum AuxDeviceError: UInt8, Codable {
  case namespaceNotSupported = 0x01
  case commandNotSupported = 0x02
  case insufficientResources = 0x03
  case invalidParameter = 0x04
  case invalidState = 0x05
  case invalidHeader = 0x06
  case invalidLength = 0x07
}

// Duke Namespace ID

enum AuxHeadphones_NamespaceId: UInt8, Codable, CaseIterable {
  case auxHeadphoneStatus = 0x00
  case auxHeadphonesManagement = 0x01
  case auxHeadphonesSettings = 0x02
  case auxHeadphonesVolume = 0x03
  case auxHeadphonePlayback = 0x04
  case auxHeadphonesPlaybackMetadata = 0x05
  case auxHeadphonesSoundSwap = 0x06
}


// Duke PDU-Specific IDs (commands and events)

enum AuxHeadphonesManagement_PduId: UInt8, Codable {
  // command
  case factoryReset = 0x03
  case getOptInFlag = 0x04
  case setOptInFlag = 0x05
}

enum AuxHeadphonesPlayback_PduId: UInt8, Codable, CaseIterable {
  // command
  case subscribe = 0x01
  case unsubscribe = 0x02
  case play = 0x03
  case pause = 0x04
  case skipToPreviousTrack = 0x05
  case skipToNextTrack = 0x06
  case getPlaybackStatus = 0x07
  // event
  case auxPlaybackStatus = 0x80
}

enum AuxHeadphonesPlaybackMEtaData_PduId: UInt8, Codable, CaseIterable {
  // command
  case subscribe = 0x01
  case unsubscribe = 0x02
  case getMetaDataStatus = 0x03
  // event
  case auxPlaybackMetadataStatus = 0x80
}

enum AuxHeadphonesSettings_PduId: UInt8, Codable, CaseIterable {
  // command
  case subscribe = 0x01
  case unsubscribe = 0x02
  case resetSettings = 0x03
  case getAncButtonCustomization = 0x04
  case getPowerButtonCustomizaition = 0x05
  case setAncButtonCustomization = 0x06
  case setButtonPowerCustomization = 0x07
  case resetCustomizations = 0x08
  case getName = 0x09
  case setName = 0x0a
  case resetProductName = 0x0b
  case getWearDetectionAction = 0x0c
  case setWearDetectionAction = 0x0d
  case getAncMode = 0x0e
  case setAncMode = 0x0f
  case getEQPreset = 0x10
  case setEQPreset = 0x11
  case getSpatialAudioMode = 0x12
  case setSpatialAudioMode = 0x13
  case getHeadTrackingMode = 0x14
  case setHeadTrackingMode = 0x15
  case getGuidance = 0x16
  case setGuidance = 0x17
  case getVoiceService = 0x18
  case setVoiceService = 0x19
  case disableVoiceService = 0x1a
  case getMaxVolume = 0x1b
  case setMaxVolume = 0x1c
  case getLowPowerMode = 0x1d
  case setLowPowerMode = 0x1e
  case getAutoOffPeriod = 0x1f
  case setAutoOffPeriod = 0x20
  case getBalance = 0x24
  case setBalance = 0x25
  // event
  case ancModeChanged = 0x80
}

enum AuxHeadphonesStatus: UInt8, Codable, CaseIterable {
  // command
  case subscribe = 0x01
  case unsubscribe = 0x02
  case getInfo = 0x03
  case getBatteryStatus = 0x04
  // event
  case auxBatteryStatus = 0x80
}

enum AuxHeadphonesVolume_PduId: UInt8, Codable, CaseIterable {
  // command
  case subscribe = 0x01
  case unsubscribe = 0x02
  case getVolume = 0x03
  case setVolume = 0x04
  // event
  case headphonesVolume = 0x80
}

enum AuxHeadphonesCommand_Anc: UInt8, Codable {
  case ancOff = 0x00
  case ancOn = 0x01
  case ambient = 0x02
}
