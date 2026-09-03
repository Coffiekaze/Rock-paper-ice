#include "player.h"
#include <iostream>
#include <string>



abilities fire = abilities::FIRE;
abilities air = abilities::AIR;
abilities water = abilities::WATER;
abilities dirt = abilities::DIRT;


void displayElements() {
    cout << "Choose an element:" << endl;
    cout << "1. Fire"  << endl;
    cout << "2. Air"   << endl;
    cout << "3. Dirt"  << endl;
    cout << "4. Water" << endl;
} 

// prints one player's health as "name hlth:x/y"
static void printHealthLine(Player& player) {
    int hp = player.getplayer_health();
    if (hp < 0) hp = 0;
    cout << player.getPlayer_name() << " hlth:"
         << hp << "/" << player.getMaxHealth() << endl;
}

// shows each player's health status at the bottom of a round
void displayHealth(Player& p1, Player& p2) {
    cout << "------ Health status ------" << endl;
    printHealthLine(p1);
    printHealthLine(p2);
    cout << "---------------------------" << endl;
}

// circular relationship: each element beats the next in the enum, loses to the
// previous, and draws with itself or its direct opposite across the cycle.
Result compareresults(abilities atk, abilities dfc){
    const int n = 4;
    int diff = (static_cast<int>(atk) - static_cast<int>(dfc) + n) % n;

    if (diff == 0) return Result::DRAW;   // same element
    if (diff == 2) return Result::DRAW;   // direct opposites cancel out
    return (diff == n - 1) ? Result::WIN : Result::LOSE;
}
