//
//  GameModel.swift
//  Rock paper ice
//
//  The Swift side of the game. All the actual RULES run in the original
//  C++ code (Engine folder) through GameEngineBridge:
//    - dice rolls        -> refmatchwithdie() in dice.cpp
//    - round totals      -> functioncheck() in dice.cpp
//    - element clash     -> compareresults() in gamelogic.cpp
//    - health & damage   -> the Player class in player.h/.cpp
//  This file only manages UI phases and mirrors the C++ state for SwiftUI.
//

import Foundation
import Combine
import SwiftUI

// MARK: - Elements (UI labels for the C++ `abilities` enum)

/// Raw values match the C++ `abilities` enum in Engine/player.h exactly:
/// FIRE=0, AIR=1, DIRT=2, WATER=3 - the order IS the beat cycle.
enum Element: Int, CaseIterable, Identifiable {
    case fire, air, dirt, water

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .fire:  return "Fire"
        case .air:   return "Air"
        case .dirt:  return "Dirt"
        case .water: return "Water"
        }
    }

    var emoji: String {
        switch self {
        case .fire:  return "🔥"
        case .air:   return "💨"
        case .dirt:  return "🪨"
        case .water: return "💧"
        }
    }

    var color: Color {
        switch self {
        case .fire:  return .orange
        case .air:   return .mint
        case .dirt:  return .brown
        case .water: return .blue
        }
    }
}

enum ClashResult {
    case win, lose, draw
}

// MARK: - Player mirror (display copy of the C++ Player state)

struct GamePlayer: Identifiable {
    let id: Int
    var name: String
    var health: Int
    let maxHealth: Int
    var die1 = 1
    var die2 = 1
    var hasRolled = false

    var diceTotal: Int { die1 + die2 }
}

// MARK: - Game phases

enum Phase: Equatable {
    case nameEntry          // welcome screen, enter names
    case rolling            // both players roll their dice
    case attackerRevealed   // announce who attacks / who defends
    case passToDefender     // "hand the phone over" cover screen
    case defencePick        // defender secretly picks an element
    case passToAttacker     // cover screen again
    case offencePick        // attacker picks an element
    case roundResult        // reveal the clash and any damage
    case gameOver           // someone ran out of hearts
}

// MARK: - Game coordinator

@MainActor
final class GameModel: ObservableObject {
    static let startingHealth = 5

    /// The bridge into the original C++ game engine.
    private let engine = GameEngineBridge()

    @Published var players: [GamePlayer] = []
    @Published var phase: Phase = .nameEntry
    @Published var attackerIndex = 0
    @Published var lastRollWasTie = false
    @Published var defenceElement: Element?
    @Published var offenceElement: Element?
    @Published var lastClash: ClashResult?
    @Published var round = 1

    var defenderIndex: Int { 1 - attackerIndex }
    var attacker: GamePlayer { players[attackerIndex] }
    var defender: GamePlayer { players[defenderIndex] }
    var bothRolled: Bool { players.allSatisfy(\.hasRolled) }
    var isGameOver: Bool { players.contains { $0.health <= 0 } }
    var winner: GamePlayer? { players.first { $0.health > 0 } }

    func startGame(name1: String, name2: String) {
        let n1 = name1.trimmingCharacters(in: .whitespaces)
        let n2 = name2.trimmingCharacters(in: .whitespaces)
        let finalName1 = n1.isEmpty ? "Player 1" : n1
        let finalName2 = n2.isEmpty ? "Player 2" : n2

        // creates the C++ Player and Dice objects and fills the dice
        engine.startGame(withName1: finalName1, name2: finalName2,
                         health: Self.startingHealth)

        players = [
            GamePlayer(id: 0, name: finalName1,
                       health: Int(engine.health(for: 0)),
                       maxHealth: Int(engine.maxHealth(for: 0))),
            GamePlayer(id: 1, name: finalName2,
                       health: Int(engine.health(for: 1)),
                       maxHealth: Int(engine.maxHealth(for: 1))),
        ]
        round = 1
        clearRoundState()
        phase = .rolling
    }

    /// Shows random tumbling faces while the roll animation plays (visual only).
    func showTumbleFaces(for index: Int) {
        players[index].die1 = Int.random(in: 1...6)
        players[index].die2 = Int.random(in: 1...6)
    }

    /// The real roll: both faces come from the C++ refmatchwithdie(),
    /// then get stored on the C++ Player with setpairdice().
    func finishRoll(for index: Int) {
        players[index].die1 = Int(engine.rollDie(for: index))
        players[index].die2 = Int(engine.rollDie(for: index))
        players[index].hasRolled = true
        engine.storeDice(for: index,
                         die1: players[index].die1,
                         die2: players[index].die2)

        guard bothRolled else { return }

        // totals come from the C++ functioncheck()
        let total0 = Int(engine.total(for: 0))
        let total1 = Int(engine.total(for: 1))

        if total0 == total1 {
            // Tie -> everyone rolls again, like the do-while reroll in main.cpp.
            lastRollWasTie = true
            players[0].hasRolled = false
            players[1].hasRolled = false
        } else {
            lastRollWasTie = false
            attackerIndex = total0 > total1 ? 0 : 1
            phase = .attackerRevealed
        }
    }

    func proceedToDefencePick() { phase = .passToDefender }
    func defenderReady()        { phase = .defencePick }
    func attackerReady()        { phase = .offencePick }

    func pickDefence(_ element: Element) {
        defenceElement = element
        phase = .passToAttacker
    }

    func pickOffence(_ element: Element) {
        offenceElement = element
        guard let defence = defenceElement else { return }

        // the clash is decided by the C++ compareresults()
        let outcome = engine.clash(withAttack: element.rawValue,
                                   defence: defence.rawValue)
        let result: ClashResult = outcome == 0 ? .win : (outcome == 1 ? .lose : .draw)
        lastClash = result

        if result == .win {
            // damage goes through the C++ Player::setPlayer_health()
            engine.damageDefender(defenderIndex)
        }
        syncHealthFromEngine()
        phase = .roundResult
    }

    func nextRound() {
        round += 1
        clearRoundState()
        phase = .rolling
    }

    func finishGame() { phase = .gameOver }

    /// Rematch with the same players at full health.
    func rematch() {
        startGame(name1: players[0].name, name2: players[1].name)
    }

    func newPlayers() { phase = .nameEntry }

    /// Mirrors the C++ Player health into the Swift structs SwiftUI renders.
    private func syncHealthFromEngine() {
        for i in players.indices {
            players[i].health = Int(engine.health(for: i))
        }
    }

    private func clearRoundState() {
        defenceElement = nil
        offenceElement = nil
        lastClash = nil
        lastRollWasTie = false
        for i in players.indices {
            players[i].hasRolled = false
            players[i].die1 = 1
            players[i].die2 = 1
        }
    }
}
