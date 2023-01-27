//
//  DeviceList.swift
//  BLESwiftUI
//
//  Created by Ashley Oldham on 13/12/2022.
//

import SwiftUI

struct DeviceList: View {
  @EnvironmentObject var viewModel: PeripheralViewModel
  @State private var spatialToggle = false
  @State private var ancToggle = false

  var body: some View {
    VStack {
      List() {
        Section("Players") {
          ForEach(viewModel.peripherals) { peripheral in
            if peripheral.name != Constants.gattServer {
              NavigationLink {
                PeripheralDetail(peripheral: peripheral, device: viewModel.devices, ancToggle: $ancToggle, spatialToggle: $spatialToggle)
              } label: {
                DeviceListRow(peripheral: peripheral)
              }
            }
          }
        }
        Section("Wearables") {
          ForEach(viewModel.peripherals) { peripheral in
            if peripheral.name == Constants.gattServer {
              NavigationLink {
                PeripheralDetail(peripheral: peripheral, device: viewModel.devices, ancToggle: $ancToggle, spatialToggle: $spatialToggle)
              } label: {
                DeviceListRow(peripheral: peripheral)
              }
            }
          }
        }
      }
      .refreshable {
        viewModel.startScanning()
      }
    }
  }
}

struct DeviceList_Previews: PreviewProvider {
  static let viewModel = PeripheralViewModel()
  static var previews: some View {
    DeviceList()
      .environmentObject(viewModel)
  }
}
