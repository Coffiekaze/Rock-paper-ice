
#include <string> 
#include "dice.h"
#include <functional>
#include <utility>
#pragma once

using namespace std;

// this shall be used to create a class for the  player and also perhaps the AI

// order IS the beat-cycle: each element beats the next (Fire->Air->Dirt->Water->Fire)
enum class abilities { FIRE, AIR, DIRT, WATER};

enum class Result { WIN, LOSE, DRAW };


class Player {
public:
  Player(int health, string name,Dice score,pair<int,int>Thedicescore);

  string getPlayer_name() { return Player_name; }

  void setPlayer_name(string nameofthePlayer) { Player_name = nameofthePlayer; }

  void setPlayer_health(int healthoftheplayer) {
    Player_health=Player_health-healthoftheplayer;
  } 
  int getplayer_health(){ 
    return Player_health;
  }
  int getMaxHealth(){
    return Player_maxhealth;
  }
    
  void setScore(Dice& setscoredice){ 
   Player_Dicescore=setscoredice;
  } 
  Dice& getdice(){
    return Player_Dicescore;
  } 
  pair<int,int> setpairdice(int thematch,int theothermatch){
    return storepairdice={thematch,theothermatch};
  } 
  pair<int,int>getpairdice(){
    return storepairdice;
  }

protected:
  int getPlayerhealth() { return Player_health; }

private:
  pair<int, int>storepairdice;
  int Player_health;
  int Player_maxhealth;
  string Player_name;
  Dice Player_Dicescore;
};

void integertostoreinteger(tvoidfunction,Player currentplayer,Dice diceforgame); 

Player& returndefendingplayer(Player&Player1, Player& Player2);
Player& returnattackinglayer(Player&Player1, Player& Player2);

void displayElements();
Result compareresults(abilities atk, abilities dfc);
void displayHealth(Player& p1, Player& p2);
void clearScreen();
void attack(string nameoftheplayer[],Player attackingplayer1,Player attackingplayer2,int total[]);
void defence(string nameoftheplayer[],Player defendingplayer1,Player defendingplayer2,int total[]);
bool returnvalue(Player& Player1,Player& Player2,bool istied);
