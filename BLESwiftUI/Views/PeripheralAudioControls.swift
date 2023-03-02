//
//  PeripheralAudioControls.swift
//  BLESwiftUI
//
//  Created by Ashley Oldham on 23/01/2023.
//

import SwiftUI

struct PeripheralAudioControls: View {
  @EnvironmentObject var viewModel: PeripheralViewModel
  @State private var playToggle = false
  @State var volumeLevel: Float

  var body: some View {
    VStack {
      HStack(spacing: 40) {
        Button {
          viewModel.skipToPreviousTrack()
        } label: {
          Image(systemName: Constants.PlaybackControlButton.previousTrackImage)
            .resizable()
            .frame(width: Constants.PlaybackControlButton.skipPreviousTrackWidth, height: Constants.PlaybackControlButton.skipPreviousTrackHeight)
            .foregroundColor(Constants.CustomColor.buttonControlColor)
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
            .foregroundColor(Constants.CustomColor.buttonControlColor) :
          Image(systemName: Constants.PlaybackControlButton.playImage)
            .resizable()
            .frame(width: Constants.PlaybackControlButton.playPauseWidth, height: Constants.PlaybackControlButton.playPauseHeight)
            .foregroundColor(Constants.CustomColor.buttonControlColor)
        }

        Button {
          viewModel.skipToNextTrack()
        } label: {
          Image(systemName: Constants.PlaybackControlButton.nextTrackImage)
            .resizable()
            .frame(width: Constants.PlaybackControlButton.skipNextTrackWidth, height: Constants.PlaybackControlButton.skipNextTrackHeight)
            .foregroundColor(Constants.CustomColor.buttonControlColor)
        }
      }

      Slider(value: $volumeLevel,
             in: 0...100,
             onEditingChanged: { (_) in
        print("control", volumeLevel)
        viewModel.device.volumeLevel = volumeLevel
        viewModel.setMaxVolumeLevel(value: volumeLevel)
        viewModel.hapticFeedback()
      },
             minimumValueLabel: Image(systemName: "\(sliderImage)"),
             maximumValueLabel: nil,
             label: { Text("") })
      .padding([.leading, .trailing])
      .tint(Constants.CustomColor.buttonControlColor)
    }
  }

  var sliderImage: String {
    switch volumeLevel {
    case 1...33:
      return "speaker.wave.1"
    case 34...66:
      return "speaker.wave.2"
    case 67...100:
      return "speaker.wave.3"
    default:
      return "speaker"
    }
  }

}

struct PeripheralAudioControls_Previews: PreviewProvider {
  static let viewModel = PeripheralViewModel()
  static var previews: some View {
    PeripheralAudioControls(volumeLevel: 88.0)
      .environmentObject(viewModel)
  }
}
