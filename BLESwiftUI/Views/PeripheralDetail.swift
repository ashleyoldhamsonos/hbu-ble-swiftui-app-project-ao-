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
  @Binding var ancToggle: Bool
  @Binding var spatialToggle: Bool
  @State var name: String?

  var body: some View {

    if !viewModel.isConnected {
      Button {
        viewModel.isConnected = true
        viewModel.connect(device: peripheral.peripheral)
      } label: {
        Text("Connect")
      }
      .buttonStyle(GrowingButton())
    } else {
      Spacer()
      ZStack {
        Rectangle()
          .fill(Color.init(.systemGray5))
          .cornerRadius(12.0)
          .frame(height: 225)
        VStack(spacing: 25) {
          Image(systemName: peripheral.icon)
            .resizable()
            .scaledToFit()
            .frame(height: 80)
          VStack(alignment: .leading, spacing: 10) {
            Text("Product Name: \(peripheral.name)")
            //      Text(peripheral.advertisingData)
//            if peripheral.name == Constants.gattServer {
            if viewModel.device.name != nil {
                Text("Device Name: \(viewModel.device.name ?? "")")
            } else {
              Text("Device Name: Unknown")
            }
            Text("RSSI: \(peripheral.rssi)")
          }
        }
      }
      .padding(.horizontal)


      Spacer()

      VStack {
        Toggle(isOn: $spatialToggle, label: {
          Text("Spatial Audio")
        }).onChange(of: spatialToggle, perform: { newValue in
          newValue ? viewModel.spatialAudioOn() : viewModel.spatialAudioOff()
        })
        .onAppear(perform: {
          if viewModel.device.getSpatialAudio ?? false {
            spatialToggle = true
          }
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
        .onAppear(perform: {
          if viewModel.device.getANCMode ?? false {
            ancToggle = true
          }
        })
        .tint(Constants.CustomColor.toggleControlColor)
        .disabled(peripheral.name == Constants.gattServer ? false : true)
        .opacity(peripheral.name == Constants.gattServer ? 1 : 0)

        ZStack {
          Rectangle()
            .fill(Color.init(.systemGray5))
            .cornerRadius(12.0)
            .frame(height: 120)
          PeripheralAudioControls(volumeLevel: viewModel.device.volumeLevel ?? 50)
        }

      }
      //    .navigationTitle(peripheral.name)
          .navigationBarTitleDisplayMode(.inline)
          .navigationBarItems(trailing: Button(action: {
            viewModel.disconnectDevice()
            viewModel.isConnected = false
          }, label: {
            Text("Disconnect")
          }))
          .padding()
    }
  }
}

//struct PeripheralDetail_Previews: PreviewProvider {
//  static let viewModel = PeripheralViewModel()
//  static var previews: some View {
//    PeripheralDetail(peripheral: viewModel.peripherals.first ?? Peripheral(id: 0, name: "Device 1", rssi: -33), ancToggle: .constant(true), spatialToggle: .constant(true))
//      .environmentObject(viewModel)
//  }
//}
