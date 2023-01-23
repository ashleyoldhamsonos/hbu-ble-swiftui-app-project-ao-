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

  var body: some View {
    HStack(spacing: 40) {
      Button {
        viewModel.skipToPreviousTrack()
      } label: {
        Image(systemName: Constants.PlaybackControlButton.previousTrackImage)
          .resizable()
          .frame(width: Constants.PlaybackControlButton.skipPreviousTrackWidth, height: Constants.PlaybackControlButton.skipPreviousTrackHeight)
          .foregroundColor(Constants.CustomColor.buttonControl)
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
          .foregroundColor(Constants.CustomColor.buttonControl) :
        Image(systemName: Constants.PlaybackControlButton.playImage)
          .resizable()
          .frame(width: Constants.PlaybackControlButton.playPauseWidth, height: Constants.PlaybackControlButton.playPauseHeight)
          .foregroundColor(Constants.CustomColor.buttonControl)
      }

      Button {
        viewModel.skipToNextTrack()
      } label: {
        Image(systemName: Constants.PlaybackControlButton.nextTrackImage)
          .resizable()
          .frame(width: Constants.PlaybackControlButton.skipNextTrackWidth, height: Constants.PlaybackControlButton.skipNextTrackHeight)
          .foregroundColor(Constants.CustomColor.buttonControl)
      }
    }
  }
}

struct PeripheralAudioControls_Previews: PreviewProvider {
  static let viewModel = PeripheralViewModel()
  static var previews: some View {
    PeripheralAudioControls()
      .environmentObject(viewModel)
  }
}
