//
//  GameEngineBridge.mm
//  Rock paper ice
//
//  Objective-C++ implementation: this file speaks both Objective-C and C++,
//  so it can hold real C++ Player/Dice objects and call the original game
//  functions from dice.cpp, player.cpp and gamelogic.cpp.
//

#import "GameEngineBridge.h"

#include "Engine/player.h"
#include <string>
#include <utility>
#include <vector>

@implementation GameEngineBridge {
    std::vector<Player> _players;
    std::vector<Dice> _dice;
}

- (void)startGameWithName1:(NSString *)name1 name2:(NSString *)name2 health:(NSInteger)health {
    _players.clear();
    _dice.clear();

    Dice::pourdie firstDieStruct;
    Dice::pourdie secondDieStruct;
    _dice.push_back(Dice(firstDieStruct));
    _dice.push_back(Dice(secondDieStruct));

    // fill both dice with faces 1-6, exactly like the terminal game does
    makediefull(_dice[0]);
    makediefull(_dice[1]);

    _players.push_back(Player((int)health, std::string([name1 UTF8String]), _dice[0], {0, 0}));
    _players.push_back(Player((int)health, std::string([name2 UTF8String]), _dice[1], {0, 0}));
}

- (NSInteger)rollDieFor:(NSInteger)playerIndex {
    return refmatchwithdie(_dice[playerIndex]);
}

- (void)storeDiceFor:(NSInteger)playerIndex die1:(NSInteger)die1 die2:(NSInteger)die2 {
    _players[playerIndex].setpairdice((int)die1, (int)die2);
}

- (NSInteger)totalFor:(NSInteger)playerIndex {
    std::pair<int, int> totals = functioncheck(_players[0].getpairdice(),
                                               _players[1].getpairdice());
    return playerIndex == 0 ? totals.first : totals.second;
}

- (NSInteger)clashWithAttack:(NSInteger)attackElement defence:(NSInteger)defenceElement {
    Result outcome = compareresults(static_cast<abilities>(attackElement),
                                    static_cast<abilities>(defenceElement));
    switch (outcome) {
        case Result::WIN:  return 0;
        case Result::LOSE: return 1;
        case Result::DRAW: return 2;
    }
}

- (void)damageDefender:(NSInteger)defenderIndex {
    // Player::setPlayer_health subtracts the amount you pass in
    _players[defenderIndex].setPlayer_health(1);
}

- (NSInteger)healthFor:(NSInteger)playerIndex {
    return _players[playerIndex].getplayer_health();
}

- (NSInteger)maxHealthFor:(NSInteger)playerIndex {
    return _players[playerIndex].getMaxHealth();
}

@end
