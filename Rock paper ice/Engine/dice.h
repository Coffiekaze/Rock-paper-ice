
#include <iostream> 
#include <cmath> 
#include <vector> 
#include <string>
#include <functional>


using namespace std; 




//this will be used  as the games die 
class Dice{

public: 

struct pourdie{
    int numberofsides[6]; 
    string Random_outcome;
}; 


Dice(pourdie gamedie); 

pourdie& getpourdie();
//should i make a dynamic object for this part  
protected:
pourdie playdie;
};


int randomInRange(int x, int y);
void loadingAnimation(const string& message, int dots, int delayMs);

class Fairwaydie:public Dice{ 
    Fairwaydie(pourdie playfair);
};

class leewaydie:public Dice{
    leewaydie(pourdie playlee);
};

typedef function<int (Dice&)> tvoidfunction;

void makediefull(Dice& diceforgame);

int matchwithdie(Dice& dicey);

vector<int> callyourselfagain(Dice& dicestest,int dicebeingrolled[2]); 

int refmatchwithdie(Dice& randomroll);

pair<int,int> functioncheck(pair<int,int>firstplayerscore,pair<int,int>secondplayerscore); 

int highestscore(int score1,int score2); 


