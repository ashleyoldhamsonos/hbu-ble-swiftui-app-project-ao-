//
//  BLESwiftUIApp.swift
//  BLESwiftUI
//
//  Created by Ashley Oldham on 13/12/2022.
//

import SwiftUI

@main
struct BLESwiftUIApp: App {
  @ObservedObject var viewModel = PeripheralViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
            .environmentObject(viewModel)
        }
    }
}
