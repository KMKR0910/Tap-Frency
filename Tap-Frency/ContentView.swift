//
//  ContentView.swift
//  Tap-Frency
//
//  Created by Kasun Rashmika on 2026-11-19.
//

import SwiftUI

struct ContentView: View {

    var body: some View {

        VStack {

            Text("0")

            Text("Time: 10")

            Button("TAP!") {

                print("Button tapped!")

            }

        }
    }
}

#Preview {
    ContentView()
}
