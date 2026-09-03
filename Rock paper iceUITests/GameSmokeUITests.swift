//
//  GameSmokeUITests.swift
//  Rock paper iceUITests
//
//  Plays one full round to prove the C++ engine bridge works end to end.
//

import XCTest

final class GameSmokeUITests: XCTestCase {

    @MainActor
    func testPlayOneRoundThroughCppEngine() throws {
        let app = XCUIApplication()
        app.launch()

        // start the game (calls the C++ Player/Dice setup)
        let play = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Let's play")).firstMatch
        XCTAssertTrue(play.waitForExistence(timeout: 10))
        play.tap()

        // roll for both players until an attacker is decided (ties re-roll)
        let continueButton = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Continue")).firstMatch
        let rollButtons = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Roll!"))
        var attempts = 0
        while !continueButton.exists && attempts < 30 {
            let roll = rollButtons.firstMatch
            if roll.exists && roll.isHittable {
                roll.tap()
            }
            usleep(1_000_000) // let the dice animation finish
            attempts += 1
        }
        XCTAssertTrue(continueButton.waitForExistence(timeout: 5), "attacker was never decided")
        continueButton.tap()

        // defender's secret element pick
        let readyDefender = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "let's go")).firstMatch
        XCTAssertTrue(readyDefender.waitForExistence(timeout: 5))
        readyDefender.tap()

        let fire = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Fire")).firstMatch
        XCTAssertTrue(fire.waitForExistence(timeout: 5))
        fire.tap()

        // attacker's pick -> triggers the C++ compareresults() + damage
        let readyAttacker = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "let's go")).firstMatch
        XCTAssertTrue(readyAttacker.waitForExistence(timeout: 5))
        readyAttacker.tap()

        let water = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Water")).firstMatch
        XCTAssertTrue(water.waitForExistence(timeout: 5))
        water.tap()

        // round result must appear - proves the whole C++ round-trip worked
        let nextRound = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Next round")).firstMatch
        let seeWinner = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "See the winner")).firstMatch
        XCTAssertTrue(nextRound.waitForExistence(timeout: 5) || seeWinner.exists,
                      "round result never appeared")
    }
}
