
#include "player.h"
#include <cstddef>
#include <iostream> 
#include <string>
#include <chrono>
#include <thread>
#include <random> 
#include <functional> 
#include <utility>

//used for creatinng an alias for data types and function types; 


Dice::Dice(pourdie gamedie){
    playdie=gamedie;
}
Fairwaydie::Fairwaydie(pourdie playfair):Dice(playfair){}
leewaydie::leewaydie(pourdie playlee):Dice(playlee){}

int randomInRange(int x, int y) {
    static mt19937 rng(random_device{}());
    uniform_int_distribution<int> dist(x, y);
    return dist(rng);
}

void loadingAnimation(const string& message, int dots, int delayMs) {
    string display = message;
    for (int i = 0; i < dots; i++) {
        display += ".";
        cout << "\r" << display << flush;
        this_thread::sleep_for(chrono::milliseconds(delayMs));
    }
    cout << endl;
}



//implementation for making the die full 
void makediefull(Dice& diceforgame){  
    int diesides= sizeof( diceforgame.getpourdie().numberofsides) / sizeof(diceforgame.getpourdie().numberofsides[0]);
    for(int i=0; i<diesides;i++){
    diceforgame.getpourdie().numberofsides[i]=i+1; 
    cout<<diceforgame.getpourdie().numberofsides[i]<<endl;
    
}  
}

Dice::pourdie& Dice::getpourdie(){ 
    return playdie;
}



//creating refactored matchwithdie 

int refmatchwithdie(Dice &dicey){
  return  dicey.getpourdie().numberofsides[(randomInRange(0, 5))];
}


//this function will be used to switch turns between players 
void swtichturns(Player Attacker,Player Defender){ 
Dice::pourdie functionpourdie;
Dice thisdie( functionpourdie);

int storedie=sizeof(thisdie.getpourdie().numberofsides)/ sizeof(thisdie.getpourdie().numberofsides[0]); 
for(int i=0;i<storedie;i++)
 Attacker.getdice().getpourdie().numberofsides[i]=0;
} 

//function for summing up the dice scores for each player it then returns the scores as a pair 

pair<int,int> functioncheck(pair<int,int>firstplayerscore,pair<int,int>secondplayerscore){ 
    //now to implement the functionality of having to calculate the sum of the scores of the dice  

pair<int,int>Total; 

int Totalscoreplayer1=firstplayerscore.first + firstplayerscore.second; 

int Totalscoreplayer2=secondplayerscore.first + secondplayerscore.second; 

Total={Totalscoreplayer1,Totalscoreplayer2};

return Total;}; 

//function for returning the player with the highest score 
Player& returndefendingplayer(Player&Player1, Player& Player2){ 
//this function returns two players 
pair<int,int>store_total;
store_total=functioncheck(Player1.getpairdice(), Player2.getpairdice()); 
if(store_total.first<store_total.second){
return Player1;
} 
else
return Player2;
}

Player& returnattackinglayer(Player&Player1, Player& Player2){ 
    //this function returns two players 
    pair<int,int>store_total;
    store_total=functioncheck(Player1.getpairdice(), Player2.getpairdice()); 
    if(store_total.first>store_total.second){
    return Player1;
    } 
    else  
    return Player2;
} 
    



//basic function to compare two numbers and then outputs the highest one 

int highestscore(int score1,int score2){ 
 if(score1>score2){ 
    return score1;
 } 
 else  
  return score2;
}

//create a function that checks if there is a tie by checking if the sum of the scores
//for both players are the same if they are then you return a value  
bool returnvalue(Player& Player1,Player& Player2,bool istied){
    pair<int,int>sumscores; 
    sumscores=functioncheck(Player1.getpairdice(), Player2.getpairdice()); 
    if(sumscores.first==sumscores.second){ 
        istied=true;
    }
        return istied;
    
}