//
//  PeripheralDetail.swift
//  BLESwiftUI
//
//  Created by Ashley Oldham on 14/12/2022.
//

import SwiftUI

struct PeripheralDetail: View {
  @EnvironmentObject var viewModel: PeripheralViewModel
  var peripheral: Peripheral
  var device: DeviceModel
  @Binding var ancToggle: Bool
  @Binding var spatialToggle: Bool

  var body: some View {
    Spacer()

    HStack(spacing: 10) {
      Image(systemName: peripheral.icon)
        .resizable()
        .scaledToFit()
        .frame(height: 60)
      VStack(alignment: .leading, spacing: 10) {
        Text("Product Name: \(peripheral.name)")
        //      Text(peripheral.advertisingData)
        if peripheral.name == Constants.gattServer {
          Text("Device Name: \(device.name ?? "")")
        } else {
          Text("Device Name: Unknown")
        }
        Text("RSSI: \(peripheral.rssi)")
      }
    }

    Spacer()

    VStack {
      Toggle(isOn: $spatialToggle, label: {
        Text("Spatial Audio")
      }).onChange(of: spatialToggle, perform: { newValue in
        newValue ? viewModel.spatialAudioOn() : viewModel.spatialAudioOff()
      })
      .tint(Constants.CustomColor.toggleControlColor)
      .disabled(peripheral.name == Constants.gattServer ? false : true)
      .opacity(peripheral.name == Constants.gattServer ? 1 : 0)

      Toggle(isOn: $ancToggle, label: {
        Text("ANC")
      }).onChange(of: ancToggle, perform: { newValue in
        if !newValue {
          viewModel.ancOff()
        } else {
          viewModel.ancOn()
        }
      })
      .tint(Constants.CustomColor.toggleControlColor)
      .disabled(peripheral.name == Constants.gattServer ? false : true)
      .opacity(peripheral.name == Constants.gattServer ? 1 : 0)

      PeripheralAudioControls()

    }
    .navigationTitle(peripheral.name)
    .navigationBarTitleDisplayMode(.inline)
    .padding()
  }
}

struct PeripheralDetail_Previews: PreviewProvider {
  static let viewModel = PeripheralViewModel()
  static var previews: some View {
    PeripheralDetail(peripheral: viewModel.peripherals.first ?? Peripheral(id: 0, name: "Device 1", rssi: -33), device: DeviceModel(), ancToggle: .constant(true), spatialToggle: .constant(true))
      .environmentObject(viewModel)
  }
}
