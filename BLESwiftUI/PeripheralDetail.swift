//
//  PeripheralDetail.swift
//  BLESwiftUI
//
//  Created by Ashley Oldham on 14/12/2022.
//

import SwiftUI

struct PeripheralDetail: View {
  @EnvironmentObject var bleManager: BLEManager
//  @ObservedObject var bleManager: BLEManager
  var peripheral: Peripheral
  @State var ancToggle = false

    var body: some View {
      Text(peripheral.name)
      Spacer()
      Text(peripheral.advertisingData)
      Spacer()
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
    }

}

struct PeripheralDetail_Previews: PreviewProvider {
  static let bleManager = BLEManager()
    static var previews: some View {
      PeripheralDetail(peripheral: bleManager.peripherals[0])
        .environmentObject(BLEManager())
    }
}
