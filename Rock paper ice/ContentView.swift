//
//  ContentView.swift
//  Rock paper ice
//
//  The SwiftUI face of Element Shuffle. All the rules live in the C++ engine
//  (Engine folder, via GameEngineBridge); these views just render the current
//  phase and forward button taps.
//

import SwiftUI

let diceFaces = ["⚀", "⚁", "⚂", "⚃", "⚄", "⚅"]

struct ContentView: View {
    @StateObject private var game = GameModel()

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.45, green: 0.2, blue: 0.75),
                                    Color(red: 0.25, green: 0.3, blue: 0.85),
                                    Color(red: 0.15, green: 0.55, blue: 0.85)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                if game.phase != .nameEntry && game.phase != .gameOver {
                    HealthBoard(players: game.players)
                }

                Spacer(minLength: 0)

                switch game.phase {
                case .nameEntry:
                    NameEntryView(game: game)
                case .rolling:
                    RollingView(game: game)
                case .attackerRevealed:
                    AttackerRevealView(game: game)
                case .passToDefender, .passToAttacker:
                    PassPhoneView(game: game)
                case .defencePick, .offencePick:
                    ElementPickView(game: game)
                case .roundResult:
                    RoundResultView(game: game)
                case .gameOver:
                    GameOverView(game: game)
                }

                Spacer(minLength: 0)
            }
            .padding()
            .animation(.spring(duration: 0.4), value: game.phase)
        }
    }
}

// MARK: - Health board (always visible during play)

struct HealthBoard: View {
    let players: [GamePlayer]

    var body: some View {
        HStack(spacing: 12) {
            ForEach(players) { player in
                VStack(spacing: 6) {
                    Text(player.name)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    HStack(spacing: 2) {
                        ForEach(0..<player.maxHealth, id: \.self) { i in
                            Text(i < player.health ? "❤️" : "🖤")
                                .font(.system(size: 15))
                        }
                    }
                }
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(.white.opacity(0.15), in: RoundedRectangle(cornerRadius: 16))
            }
        }
    }
}

// MARK: - Welcome / name entry

struct NameEntryView: View {
    @ObservedObject var game: GameModel
    @State private var name1 = ""
    @State private var name2 = ""

    var body: some View {
        VStack(spacing: 22) {
            Text("🔥💨🪨💧")
                .font(.system(size: 46))
            Text("Element Shuffle")
                .font(.system(size: 40, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            Text("Roll high. Pick smart. Steal hearts.")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.85))

            VStack(spacing: 12) {
                TextField("Player 1 name", text: $name1)
                TextField("Player 2 name", text: $name2)
            }
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal, 20)

            Button {
                game.startGame(name1: name1, name2: name2)
            } label: {
                Text("Let's play! 🎲")
                    .font(.title2.bold())
                    .foregroundStyle(.black)
                    .padding(.horizontal, 36)
                    .padding(.vertical, 14)
                    .background(.yellow, in: Capsule())
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Dice rolling

struct RollingView: View {
    @ObservedObject var game: GameModel
    @State private var rollingPlayer: Int? = nil

    var body: some View {
        VStack(spacing: 18) {
            Text("Round \(game.round)")
                .font(.title.bold())
                .foregroundStyle(.white)

            if game.lastRollWasTie {
                Text("It's a tie! Both of you roll again 🤯")
                    .font(.headline)
                    .foregroundStyle(.yellow)
            } else {
                Text("Highest total gets to attack ⚔️")
                    .foregroundStyle(.white.opacity(0.85))
            }

            ForEach(game.players) { player in
                DiceCard(player: player,
                         isRolling: rollingPlayer == player.id,
                         roll: { startRoll(for: player.id) })
            }
        }
    }

    private func startRoll(for index: Int) {
        guard rollingPlayer == nil, !game.players[index].hasRolled else { return }
        rollingPlayer = index
        Task {
            for _ in 0..<8 {
                game.showTumbleFaces(for: index)
                try? await Task.sleep(nanoseconds: 80_000_000)
            }
            game.finishRoll(for: index)
            rollingPlayer = nil
        }
    }
}

struct DiceCard: View {
    let player: GamePlayer
    let isRolling: Bool
    let roll: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(player.name)
                    .font(.headline)
                    .foregroundStyle(.white)
                if player.hasRolled {
                    Text("Total: \(player.diceTotal)")
                        .font(.title3.bold())
                        .foregroundStyle(.yellow)
                } else {
                    Text(isRolling ? "Rolling…" : "Waiting to roll")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }

            Spacer()

            if player.hasRolled || isRolling {
                Text(diceFaces[player.die1 - 1])
                    .font(.system(size: 54))
                    .foregroundStyle(.white)
                    .rotationEffect(.degrees(isRolling ? 12 : 0))
                Text(diceFaces[player.die2 - 1])
                    .font(.system(size: 54))
                    .foregroundStyle(.white)
                    .rotationEffect(.degrees(isRolling ? -12 : 0))
            } else {
                Button(action: roll) {
                    Text("🎲 Roll!")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(.yellow, in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(.white.opacity(0.15), in: RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Attacker announcement

struct AttackerRevealView: View {
    @ObservedObject var game: GameModel

    var body: some View {
        VStack(spacing: 18) {
            Text("⚔️")
                .font(.system(size: 60))
            Text("\(game.attacker.name) rolled \(game.attacker.diceTotal) vs \(game.defender.diceTotal)")
                .font(.title3)
                .foregroundStyle(.white.opacity(0.9))
                .multilineTextAlignment(.center)
            Text("\(game.attacker.name) ATTACKS!")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundStyle(.yellow)
            Text("\(game.defender.name) has to defend 🛡️")
                .font(.headline)
                .foregroundStyle(.white)

            Button {
                game.proceedToDefencePick()
            } label: {
                Text("Continue ▶️")
                    .font(.title3.bold())
                    .foregroundStyle(.black)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(.yellow, in: Capsule())
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - "Hand the phone over" cover screen

struct PassPhoneView: View {
    @ObservedObject var game: GameModel

    private var targetName: String {
        game.phase == .passToDefender ? game.defender.name : game.attacker.name
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("🤫")
                .font(.system(size: 64))
            Text("Secret pick!")
                .font(.title.bold())
                .foregroundStyle(.white)
            Text("Hand the phone to \(targetName) — no peeking!")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.85))
                .multilineTextAlignment(.center)

            Button {
                if game.phase == .passToDefender {
                    game.defenderReady()
                } else {
                    game.attackerReady()
                }
            } label: {
                Text("I'm \(targetName), let's go!")
                    .font(.title3.bold())
                    .foregroundStyle(.black)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                    .background(.yellow, in: Capsule())
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Element selection

struct ElementPickView: View {
    @ObservedObject var game: GameModel

    private var isDefencePick: Bool { game.phase == .defencePick }

    var body: some View {
        VStack(spacing: 18) {
            Text(isDefencePick ? "🛡️" : "⚔️")
                .font(.system(size: 50))
            Text(isDefencePick
                 ? "\(game.defender.name), pick your shield"
                 : "\(game.attacker.name), pick your attack")
                .font(.title2.bold())
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                ForEach(Element.allCases) { element in
                    Button {
                        if isDefencePick {
                            game.pickDefence(element)
                        } else {
                            game.pickOffence(element)
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Text(element.emoji)
                                .font(.system(size: 48))
                            Text(element.displayName)
                                .font(.headline)
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(element.color.opacity(0.85),
                                    in: RoundedRectangle(cornerRadius: 20))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)

            Text("🔥 beats 💨 beats 🪨 beats 💧 beats 🔥\nopposites cancel each other out ✨")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Round result

struct RoundResultView: View {
    @ObservedObject var game: GameModel

    private var resultText: String {
        switch game.lastClash {
        case .win:
            return "💥 Direct hit! \(game.defender.name) loses a heart!"
        case .lose:
            return "🛡️ Blocked! \(game.defender.name)'s \(game.defenceElement?.displayName ?? "") shuts it down!"
        case .draw:
            return "✨ The elements cancel out. No damage!"
        case nil:
            return ""
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 18) {
                VStack {
                    Text(game.offenceElement?.emoji ?? "")
                        .font(.system(size: 64))
                    Text(game.attacker.name)
                        .font(.caption.bold())
                        .foregroundStyle(.white.opacity(0.8))
                }
                Text("⚡️")
                    .font(.system(size: 40))
                VStack {
                    Text(game.defenceElement?.emoji ?? "")
                        .font(.system(size: 64))
                    Text(game.defender.name)
                        .font(.caption.bold())
                        .foregroundStyle(.white.opacity(0.8))
                }
            }

            Text(resultText)
                .font(.title3.bold())
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Button {
                if game.isGameOver {
                    game.finishGame()
                } else {
                    game.nextRound()
                }
            } label: {
                Text(game.isGameOver ? "See the winner 👑" : "Next round ▶️")
                    .font(.title3.bold())
                    .foregroundStyle(.black)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(.yellow, in: Capsule())
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Game over

struct GameOverView: View {
    @ObservedObject var game: GameModel

    var body: some View {
        VStack(spacing: 20) {
            Text("🏆")
                .font(.system(size: 80))
            Text("\(game.winner?.name ?? "Someone") wins!")
                .font(.system(size: 34, weight: .black, design: .rounded))
                .foregroundStyle(.yellow)
                .multilineTextAlignment(.center)
            Text("What a battle of the elements! 🔥💧")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.85))

            Button {
                game.rematch()
            } label: {
                Text("Rematch! 🔁")
                    .font(.title3.bold())
                    .foregroundStyle(.black)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(.yellow, in: Capsule())
            }
            .buttonStyle(.plain)

            Button {
                game.newPlayers()
            } label: {
                Text("New players")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.85))
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    ContentView()
}
