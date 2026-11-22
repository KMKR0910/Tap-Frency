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
    
    @State private var peakScore = 0
    @State private var justFilledStar = -1    
    
    
    @State private var scorePulse = false
    
    private var starsFilled: Int {
        min(3, peakScore / 20)
    }

    private var starProgress: Double {
        peakScore >= 60 ? 1.0 : Double(peakScore % 20) / 20.0
    }

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
            
            VStack(spacing: 8) {

                HStack(spacing: 12) {
                    ForEach(0..<3, id: \.self) { index in
                        Image(systemName: index < starsFilled ? "star.fill" : "star")
                            .font(.system(size: 32))
                            .foregroundStyle(index < starsFilled ? .yellow : .white.opacity(0.25))
                            .shadow(
                                color: index < starsFilled ? .yellow.opacity(0.7) : .clear,
                                radius: 8
                            )
                            .scaleEffect(justFilledStar == index ? 1.4 : 1.0)
                            .animation(
                                .spring(response: 0.3, dampingFraction: 0.4),
                                value: justFilledStar
                            )
                    }
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(.white.opacity(0.15))
                        Capsule()
                            .fill(.yellow)
                            .frame(width: geo.size.width * starProgress)
                    }
                }
                .frame(width: 140, height: 6)
                .animation(.easeOut(duration: 0.25), value: starProgress)
            }
            .onChange(of: starsFilled) { oldValue, newValue in
                guard newValue > oldValue, newValue > 0 else { return }
                justFilledStar = newValue - 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    justFilledStar = -1
                }
            }

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
                    .tracking(3)          
                    .foregroundStyle(.white.opacity(0.5))
                    .scaleEffect(scorePulse ? 1.2 : 1.0)
                    .animation(.spring(response: 0.2, dampingFraction: 0.4), value: scorePulse)
                    .onChange(of: score) { oldValue, newValue in
                        guard newValue > oldValue else { return }
                        scorePulse = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            scorePulse = false
                        }
                    }
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
                .buttonStyle(SquishyButtonStyle())
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
        peakScore = max(peakScore, score)
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
        peakScore = 0
        timeRemaining = 10
        combo = 1
        lastTapTime = nil

        trapCycleID += 1
        isTrapActive = false

        phase = .idle
    }
}
struct SquishyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(
                .spring(response: 0.25, dampingFraction: 0.55),
                value: configuration.isPressed
            )
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
