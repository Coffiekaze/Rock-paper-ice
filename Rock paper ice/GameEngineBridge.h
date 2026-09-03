//
//  GameEngineBridge.h
//  Rock paper ice
//
//  Pure Objective-C interface that Swift can see. The implementation
//  (GameEngineBridge.mm) calls straight into the original C++ game code
//  in the Engine folder.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GameEngineBridge : NSObject

/// Creates the two C++ Player objects and fills both dice (makediefull).
- (void)startGameWithName1:(NSString *)name1 name2:(NSString *)name2 health:(NSInteger)health;

/// Rolls one die face for a player using the C++ refmatchwithdie().
- (NSInteger)rollDieFor:(NSInteger)playerIndex;

/// Stores a player's two dice with the C++ Player::setpairdice().
- (void)storeDiceFor:(NSInteger)playerIndex die1:(NSInteger)die1 die2:(NSInteger)die2;

/// A player's round total, computed by the C++ functioncheck().
- (NSInteger)totalFor:(NSInteger)playerIndex;

/// Element clash decided by the C++ compareresults().
/// Returns 0 = attacker wins, 1 = attack blocked, 2 = draw.
- (NSInteger)clashWithAttack:(NSInteger)attackElement defence:(NSInteger)defenceElement;

/// Removes 1 health via the C++ Player::setPlayer_health().
- (void)damageDefender:(NSInteger)defenderIndex;

/// Health values straight from the C++ Player object.
- (NSInteger)healthFor:(NSInteger)playerIndex;
- (NSInteger)maxHealthFor:(NSInteger)playerIndex;

@end

NS_ASSUME_NONNULL_END
