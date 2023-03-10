//
//  ContentView.swift
//  BLESwiftUI
//
//  Created by Ashley Oldham on 13/12/2022.
//

import SwiftUI

struct ContentView: View {
  
    var body: some View {
      NavigationView {
        VStack {
          DeviceList()
            .navigationBarTitle("Devices", displayMode: .automatic)
          Spacer()
          Divider()
          ScanControls()
        }
      }
    }
}

struct ContentView_Previews: PreviewProvider {
  static let viewModel = PeripheralViewModel()
    static var previews: some View {
        ContentView()
        .environmentObject(viewModel)
    }
}
