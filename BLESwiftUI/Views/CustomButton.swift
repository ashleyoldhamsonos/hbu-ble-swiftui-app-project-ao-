//
//  CustomButton.swift
//  BLESwiftUI
//
//  Created by Ashley Oldham on 14/12/2022.
//

import SwiftUI

struct GrowingButton: ButtonStyle {
  @Environment(\.colorScheme) var colorScheme

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .padding()
      .frame(minWidth: 0, maxWidth: 300)
      .background(colorScheme == .dark ? .white : .black)
      .foregroundColor(colorScheme == .dark ? .black : .white)
      .clipShape(RoundedRectangle(cornerRadius: 16))
      .scaleEffect(configuration.isPressed ? 1.2 : 1)
      .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
  }
}

struct CustomButton: View {
  var body: some View {
    Button {
      print("clicked")
    } label: {
      Text("click it")
        .font(.title2)
    }
    .buttonStyle(GrowingButton())
  }
}

struct CustomButton_Previews: PreviewProvider {
  static var previews: some View {
    CustomButton()
  }
}
