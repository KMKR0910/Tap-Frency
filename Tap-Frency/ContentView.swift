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
                .font(.system(size: 80, weight: .heavy))
                .foregroundStyle(.white)

            Text("SCORE")
                .font(.headline)
                .foregroundStyle(.gray)
            
            Button {

                print("Button tapped!")

            } label: {

                Text("TAP!")
                    .font(.system(size: 35, weight: .heavy))
                    .foregroundStyle(.white)
                    .frame(width: 200, height: 200)
                    .background(.blue)
                    .clipShape(Circle())

            }

        }
    }
}

#Preview {
    ContentView()
}
