//
//  ContentView.swift
//  Tap-Frency
//
//  Created by Kasun Rashmika on 2026-11-19.
//


import SwiftUI
import Combine

struct ContentView: View {

    @State private var score = 0
    @State private var timeRemaining = 10
    @State private var phase: GamePhase = .idle
    
    @State private var combo = 1
    @State private var lastTapTime: Date? = nil
    
    
    @AppStorage("highScore") private var highScore = 0

    private let timer = Timer.publish(
        every: 1,
        on: .main,
        in: .common
    ).autoconnect()

    
    
    var body: some View {
        VStack(spacing: 35) {

            Text("Time: \(timeRemaining)")
                .font(.title)
                .foregroundStyle(.blue)

            HStack(spacing: 12) {

                Text("\(score)")
                    .font(.system(size: 80, weight: .heavy))
                    .foregroundStyle(.black)

                if combo > 1 {

                    Text("x\(combo)!")
                        .font(.system(size: 30, weight: .heavy))
                        .foregroundStyle(.yellow)

                }

            }

            Text("SCORE")
                .font(.headline)
                .foregroundStyle(.gray)
            
            
            
            

            if phase == .over {

                VStack(spacing: 20) {

                    Text("GAME OVER!")
                        .font(.system(size: 35, weight: .heavy))
                        .foregroundStyle(.red)

                    Text("Final Score: \(score)")
                        .font(.title2)
                        .foregroundStyle(.white)
                    
                    Text("Best: \(highScore)")
                        .font(.title3)
                        .foregroundStyle(.yellow)
                    
                    Button("PLAY AGAIN") {

                     restartGame()

                    }
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.white)
                    .padding()
                    .background(.green)
                    .clipShape(RoundedRectangle(cornerRadius: 15))

                }
                
                

            } else {

                Button {

                    if phase == .idle {
                        phase = .playing
                    }

                    if phase == .playing {
                        handleTap()
                    }

                } label: {

                    Text(phase == .idle ? "START!" : "TAP!")
                        .font(.system(size: 35, weight: .heavy))
                        .foregroundStyle(.white)
                        .frame(width: 200, height: 200)
                        .background(.blue)
                        .clipShape(Circle())

                }

            }
            
            
        }
        
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)
        .onReceive(timer) { _ in
            
            if phase == .playing {
                if timeRemaining > 0 {
                    timeRemaining -= 1
                }
                
                if timeRemaining == 0 {

                    phase = .over

                    if score > highScore {
                        highScore = score
                    }

                }
            }
        }
 
    }
    
    private func handleTap() {

        let currentTime = Date()

        if let lastTap = lastTapTime {

            let timeDifference = currentTime.timeIntervalSince(lastTap)

            if timeDifference <= 0.3 {
                combo += 1
            } else {
                combo = 1
            }

        } else {

            combo = 1

        }

        score += combo

        lastTapTime = currentTime

    }
    private func restartGame() {

        score = 0
        timeRemaining = 10
        combo = 1
        lastTapTime = nil

        phase = .idle

    }
}

enum GamePhase{
    case idle
    case playing
    case over
    
}
#Preview {
    ContentView()}


