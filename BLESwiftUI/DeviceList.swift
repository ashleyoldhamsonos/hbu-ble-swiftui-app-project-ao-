//
//  DeviceList.swift
//  BLESwiftUI
//
//  Created by Ashley Oldham on 13/12/2022.
//

import SwiftUI

struct DeviceList: View {
  @ObservedObject var bleManager = BLEManager()
//  @ObservedObject var peripheralViewModel = PeripheralViewModel()
  @State var toggle = true

  var body: some View {
    VStack {
      NavigationView {
        List() {
          ForEach(bleManager.peripherals) { peripheral in
            NavigationLink {
              PeripheralDetail(bleManager: bleManager, peripheral: peripheral)
            } label: {
              HStack {
                Text(peripheral.name)
                Spacer()
                Text(String(peripheral.rssi))
              }
            }
          }
        }
        .navigationBarTitle("Devices", displayMode: .automatic)
      }
      Divider()
      Text("STATUS")
        .font(.headline)
      if bleManager.isBluetoothOn {
        Text("Bluetooth is swithced on")
          .foregroundColor(.green)
      } else {
        Text("Bluetooth is switched off")
          .foregroundColor(.red)
      }
      Spacer()
      HStack {
        VStack {
          Button {
            if toggle {
              bleManager.startScanning()
              toggle = false
            } else {
              bleManager.stopScanning()
              toggle = true
            }
          } label: {
            toggle ? Text("Start Scan") : Text("Stop Scan")
          }
          .buttonStyle(GrowingButton())
        }
      }
      //      Spacer()
    }
  }
}

struct DeviceList_Previews: PreviewProvider {
  static var previews: some View {
    DeviceList()
  }
}
