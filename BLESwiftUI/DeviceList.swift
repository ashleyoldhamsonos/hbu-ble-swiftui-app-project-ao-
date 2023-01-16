//
//  DeviceList.swift
//  BLESwiftUI
//
//  Created by Ashley Oldham on 13/12/2022.
//

import SwiftUI

struct DeviceList: View {
  @EnvironmentObject var bleManager: BLEManager

  var body: some View {
    VStack {
      List() {
        ForEach(bleManager.peripherals) { peripheral in
          NavigationLink {
            PeripheralDetail(peripheral: peripheral, device: bleManager.devices)
          } label: {
            HStack {
              Text(peripheral.name)
              Spacer()
              Text(String(peripheral.rssi))
            }
          }
        }
      }
    }
  }
}

struct DeviceList_Previews: PreviewProvider {
  static var bleManager = BLEManager()
  static var previews: some View {
    DeviceList()
      .environmentObject(bleManager)
  }
}
