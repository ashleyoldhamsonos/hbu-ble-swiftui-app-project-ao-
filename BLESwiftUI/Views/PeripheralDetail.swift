//
//  PeripheralDetail.swift
//  BLESwiftUI
//
//  Created by Ashley Oldham on 14/12/2022.
//

import SwiftUI

struct PeripheralDetail: View {
  //  @EnvironmentObject var bleManager: BLEManager
  @EnvironmentObject var viewModel: PeripheralViewModel
  var peripheral: Peripheral
  var device: DeviceModel
  @State private var ancToggle = false
  @State private var playToggle = false
  @State private var spatialToggle = false
  @State private var enabledControls = false

  var body: some View {
    Spacer()

    VStack(spacing: 10) {
      Text("Product Name: \(peripheral.name)")
      //      Text(peripheral.advertisingData)
      if peripheral.name == Constants.gattServer {
        Text("Device Name: \(device.name ?? "")")
      } else {
        Text("Device Name: Unknown")
      }
    }

    Spacer()

    VStack {
      Toggle(isOn: $spatialToggle, label: {
        Text("Spatial Audio")
      }).onChange(of: spatialToggle, perform: { newValue in
        newValue ? viewModel.spatialAudioOn() : viewModel.spatialAudioOff()
      })
      .disabled(peripheral.name == Constants.gattServer ? false : true)

      Toggle(isOn: $ancToggle, label: {
        Text("ANC")
      }).onChange(of: ancToggle, perform: { newValue in
        if !newValue {
          viewModel.ancOff()
        } else {
          viewModel.ancOn()
        }
      })
      .disabled(peripheral.name == Constants.gattServer ? false : true)

      HStack(spacing: 40) {
        Button {
          viewModel.skipToPreviousTrack()
        } label: {
          Image(systemName: Constants.PlaybackControlButton.previousTrackImage)
            .resizable()
            .frame(width: Constants.PlaybackControlButton.skipPreviousTrackWidth, height: Constants.PlaybackControlButton.skipPreviousTrackHeight)
            .foregroundColor(.white)
        }

        Button {
          if playToggle != true {
            viewModel.playCommand()
            playToggle = true
          } else {
            viewModel.pauseCommand()
            playToggle = false
          }
        } label: {
          playToggle ?
          Image(systemName: Constants.PlaybackControlButton.pauseImage)
            .resizable()
            .frame(width: Constants.PlaybackControlButton.playPauseWidth, height: Constants.PlaybackControlButton.playPauseHeight)
            .foregroundColor(.white) :
          Image(systemName: Constants.PlaybackControlButton.playImage)
            .resizable()
            .frame(width: Constants.PlaybackControlButton.playPauseWidth, height: Constants.PlaybackControlButton.playPauseHeight)
            .foregroundColor(.white)
        }
        .controlSize(.regular)

        Button {
          viewModel.skipToNextTrack()
        } label: {
          Image(systemName: Constants.PlaybackControlButton.nextTrackImage)
            .resizable()
            .frame(width: Constants.PlaybackControlButton.skipNextTrackWidth, height: Constants.PlaybackControlButton.skipNextTrackHeight)
            .foregroundColor(.white)
        }
      }
    }
    .navigationTitle(peripheral.name)
    .navigationBarTitleDisplayMode(.inline)
    .padding()
  }
}

struct PeripheralDetail_Previews: PreviewProvider {
  //  static let bleManager = BLEManager()
  static let viewModel = PeripheralViewModel()
  static var previews: some View {
    PeripheralDetail(peripheral: viewModel.peripherals.first ?? Peripheral(id: 0, name: "Device 1", rssi: -33), device: DeviceModel())
      .environmentObject(viewModel)
  }
}
