//
//  ScanControls.swift
//  BLESwiftUI
//
//  Created by Ashley Oldham on 22/12/2022.
//

import SwiftUI

struct ScanControls: View {
  @EnvironmentObject var viewModel: PeripheralViewModel

  var body: some View {
    VStack {
      Text("STATUS")
        .font(.headline)
      if BLEManager.shared.isBluetoothOn {
        Text("Bluetooth is swithced on")
          .foregroundColor(.green)
      } else {
        Text("Bluetooth is switched off")
          .foregroundColor(.red)
      }
      HStack {
        VStack {
          Button {
            viewModel.startScanning()
          } label: {
            Text("Start Scan")
          }
          .buttonStyle(GrowingButton())
        }
      }
    }
  }
}

struct ScanControls_Previews: PreviewProvider {
  static let viewModel = PeripheralViewModel()
  static var previews: some View {
    ScanControls()
      .environmentObject(viewModel)
  }
}
