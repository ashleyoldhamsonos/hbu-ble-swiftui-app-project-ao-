//
//  DeviceListCell.swift
//  BLESwiftUI
//
//  Created by Ashley Oldham on 27/01/2023.
//

import SwiftUI

struct DeviceListRow: View {

  let peripheral: Peripheral

    var body: some View {
      HStack {
        Image(systemName: peripheral.icon)
        Text(peripheral.name)
        Spacer()
        Text(String(peripheral.rssi))
      }
    }
}

struct DeviceListRow_Previews: PreviewProvider {
    static var previews: some View {
      DeviceListRow(peripheral: Peripheral(id: 0, name: "iPhone", rssi: -33))
    }
}
