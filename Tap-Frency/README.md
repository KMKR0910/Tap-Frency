
# Tap Frenzy 

A fast-reflex iOS tap game built with **SwiftUI**. Tap as many times as you can in
10 seconds, chain fast taps to build a combo, and dodge the red **TRAP!** state —
hitting it costs points and resets your streak.

Built for learning SwiftUI and evolving into a kid-friendly version with stars,
bars, and celebrations.

---

## ✨ Features (Tutorial 1)

### Core gameplay
- **10-second timed rounds** — score as many points as possible before the clock hits zero.
- **Combo system** — tap within 0.3 s of your last tap to grow the multiplier
  (`x2`, `x3`, `x4`…). Pause and it resets to `x1`.
- **Trap cycles** — the button randomly turns red (`TRAP!`) for 0.5 s every 2–5 s.
  Tapping during a trap costs **2 points** and resets the combo.
- **Three-phase game flow** — `idle` → `playing` → `over` → `idle` again.

### Persistence
- **High score** saved with `@AppStorage` (survives app relaunch).

---

##  ✨ How to play

| Action | Result |
|---|---|
| Tap **START!** | Begins a 10-second round |
| Tap **TAP!** (blue) | Adds `combo` points |
| Tap fast (≤ 0.3 s between taps) | Combo multiplier increases |
| Tap **TRAP!** (red) | −2 points, combo resets to 1 |
| Timer hits 0 | Round ends, high score saved if beaten |
| Tap **PLAY AGAIN** | Returns to the start screen |

### Inside `ContentView.swift`

| Type | Purpose |
|---|---|
| `ContentView` | The whole screen — holds all game state and builds the UI |
| `GamePhase` (enum) | The three game states: `.idle`, `.playing`, `.over` |
| 

| Function | What it does |
|---|---|
| `handleTap()` | Scores a tap, evaluates combo timing, applies trap penalty |
| `startTrapCycle()` | Schedules the next trap, turns it on for 0.5 s, reschedules itself |
| `endGame()` | Switches to `.over`, cancels pending traps, saves high score |
| `restartGame()` | Resets all state back to `.idle` for another round |

---

## ✨ Built with

- **Swift 5.9+**
- **SwiftUI** — view composition, animations, `@State`, `@AppStorage`, `ButtonStyle`
- **Combine** — `Timer.publish(...).autoconnect()` for the 1-second tick
- **SF Symbols** — `star` / `star.fill` for the star meter (no image assets needed)


## ✨ Author

**K.M.K Rashmika** — created November 2026.
