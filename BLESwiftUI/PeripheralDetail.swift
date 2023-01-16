//
//  PeripheralDetail.swift
//  BLESwiftUI
//
//  Created by Ashley Oldham on 14/12/2022.
//

import SwiftUI

struct PeripheralDetail: View {
  @EnvironmentObject var bleManager: BLEManager
  var peripheral: Peripheral
  var device: DeviceModel
  @State private var ancToggle = false
  @State private var playToggle = false
  @State private var spatialToggle = false

    var body: some View {
      Spacer()
      Text("Product Name: \(peripheral.name)")
//      Text(peripheral.advertisingData)
      Text("Device Name: \(device.name ?? "name unknown")")
      Text("Spatial Audio: \(device.getSpatialAudio ?? "unavailable")")
      Spacer()
      VStack {
        Toggle("Spatial Audio", isOn: $spatialToggle)

        if spatialToggle {
          // handle label for ON
        } else {
          // handle label for OFF
        }
        Button {
          if ancToggle != true {
            bleManager.ancOn()
            ancToggle = true
          } else {
            bleManager.ancOff()
            ancToggle = false
          }
        } label: {
          ancToggle ? Text("ANC Off") : Text("ANC On")
        }
      .buttonStyle(GrowingButton())
        Button {
          if playToggle != true {
            bleManager.playCommand()
            playToggle = true
          } else {
            bleManager.pauseCommand()
            playToggle = false
          }
        } label: {
          playToggle ? Text("Pause") : Text("Play")
        }
        .buttonStyle(GrowingButton())
      }
      .navigationTitle(peripheral.name)
      .navigationBarTitleDisplayMode(.inline)

    }

}

struct PeripheralDetail_Previews: PreviewProvider {
  static let bleManager = BLEManager()
    static var previews: some View {
      PeripheralDetail(peripheral: bleManager.peripherals.first ?? Peripheral(id: 0, name: "Device 1", rssi: -33), device: DeviceModel())
    }
}
