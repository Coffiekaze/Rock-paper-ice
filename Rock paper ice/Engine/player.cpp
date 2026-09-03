#include "player.h" 
#include <cstdlib>
#include <iostream>
#include <string>
#include <utility>
#ifdef __APPLE__
#include <TargetConditionals.h>
#endif

using namespace std;

Player::Player(int health, string name,Dice score,pair<int, int>Thedicescore)
    : storepairdice{0,0}, Player_health(health), Player_maxhealth(health), Player_name(name), Player_Dicescore(score){};

void clearScreen() {
#if defined(_WIN32)
  std::system("cls");
#elif defined(__APPLE__) && TARGET_OS_IPHONE
  // iOS has no terminal to clear - nothing to do
#else
  std::system("clear");
#endif
}
//used to decide who is the attacking player 
void attack(string nameoftheplayer[],Player attackingplayer1,Player attackingplayer2,int total[]){
  if(attackingplayer1.getpairdice().first+attackingplayer1.getpairdice().second==highestscore(total[0], total[1])){
    cout<<nameoftheplayer[0]<<" gets to attack "<<nameoftheplayer[1]<<" has to defend"<<endl; 
 }
  else if(attackingplayer2.getpairdice().first+attackingplayer2.getpairdice().second==highestscore(total[0], total[1])){ 
   cout<<nameoftheplayer[1]<< " gets to attack "<<nameoftheplayer[0]<<" has to defend"<<endl;
 } 
} 
//used to decide who is the defending player 
void defence(string nameoftheplayer[],Player defendingplayer1,Player defendingplayer2,int total[]){ 
  if(defendingplayer1.getpairdice().first+defendingplayer1.getpairdice().second!=highestscore(total[0], total[1])){
    cout<<nameoftheplayer[0]<<" has to defend "<<nameoftheplayer[1]<<" has to attack"<<endl; 
 }
  else if(defendingplayer2.getpairdice().first+defendingplayer2.getpairdice().second==highestscore(total[0], total[1])){ 
   cout<<nameoftheplayer[1]<< " gets to attack "<<nameoftheplayer[0]<<" has to defend"<<endl;
 } 


}

//dont you just love encapsulation 
//this function is used to store Diceroll numbers for each round
//void integertostoreinteger(tvoidfunction thisfunction,Player currentPlayer,Dice theplayers_dice){
//  int i;
 // currentPlayer.setScore(theplayers_dice);
 // for(i=0;i<2;i++){
   // currentPlayer.getdice().getpourdie().numberofsides[i]=thisfunction(theplayers_dice);
//  }
//}
 
