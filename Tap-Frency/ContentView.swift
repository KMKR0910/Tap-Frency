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

    @State private var isTrapActive = false
    @State private var trapCycleID = 0

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

            VStack(spacing: 4) {
                HStack(spacing: 12) {
                    Text("\(score)")
                        .font(.system(size: 80, weight: .heavy))
                        .foregroundStyle(.white)

                    if combo > 1 {
                        Text("x\(combo)!")
                            .font(.system(size: 30, weight: .heavy))
                            .foregroundStyle(.yellow)
                    }
                }

                Text("SCORE")
                    .font(.caption)
                    .fontWeight(.bold)
                    .tracking(3)          // letter-spacing — "SCORE" gets a HUD look
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))

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
                        startTrapCycle()
                    }

                    if phase == .playing {
                        handleTap()
                    }

                } label: {

                    Text(
                        phase == .idle
                        ? "START!"
                        : (isTrapActive ? "TRAP!" : "TAP!")
                    )
                    .font(.system(size: 35, weight: .heavy))
                    .foregroundStyle(.white)
                    .frame(width: 200, height: 200)
                    .background(isTrapActive ? Color.red : Color.blue)
                    .clipShape(Circle())
                    .shadow(
                        color: (isTrapActive ? Color.red : Color.blue).opacity(0.8),
                        radius: 40
                    )
                    .animation(.easeInOut(duration: 0.1), value: isTrapActive)
                }
                .buttonStyle(.plain)
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RadialGradient(
                colors: [
                    Color(red: 0.10, green: 0.12, blue: 0.30),
                    Color(red: 0.02, green: 0.02, blue: 0.08)   
                ],
                center: .center,
                startRadius: 40,
                endRadius: 500
            )
            .ignoresSafeArea()
        )
        .onReceive(timer) { _ in

            if phase == .playing {

                if timeRemaining > 0 {
                    timeRemaining -= 1
                }

                if timeRemaining == 0 {
                    endGame()
                }
            }
        }
    }

    private func handleTap() {

        if isTrapActive {
            score = max(0, score - 2)
            combo = 1
            lastTapTime = nil
            return
        }

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

    private func startTrapCycle() {

        guard phase == .playing else {
            return
        }

        let delay = Double.random(in: 2.0...5.0)
        let currentCycleID = trapCycleID

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {

            guard phase == .playing,
                  trapCycleID == currentCycleID else {
                return
            }

            isTrapActive = true
            combo = 1
            lastTapTime = nil

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {

                guard phase == .playing,
                      trapCycleID == currentCycleID else {
                    return
                }

                isTrapActive = false
                startTrapCycle()
            }
        }
    }

    private func endGame() {

        phase = .over
        trapCycleID += 1
        isTrapActive = false

        if score > highScore {
            highScore = score
        }
    }

    private func restartGame() {

        score = 0
        timeRemaining = 10
        combo = 1
        lastTapTime = nil

        trapCycleID += 1
        isTrapActive = false

        phase = .idle
    }
}

enum GamePhase {
    case idle
    case playing
    case over
}

#Preview {
    ContentView()
}
