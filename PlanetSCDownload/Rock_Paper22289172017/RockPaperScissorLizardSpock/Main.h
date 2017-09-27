#ifndef MAIN_H
#define MAIN_H

#include <vector>
#include <string>

enum Choice {PAPER, SCISSOR, ROCK, LIZARD, SPOCK, QUIT};

enum Result {PLAYER_WON, COMPUTER_WON, DRAW};

struct Rule
{
  Choice player;
  Choice comp;
  Result result;
};

Choice getPlayerChoice();
Choice getComputerChoice();

Result getResult(Choice player, Choice comp);
void showResult(Choice playerChoice, Choice computerChoice, Result result);

std::string toLower(const std::string& s);
std::string toString(Choice choice);
void pause();
 
const std::vector<Rule> Rules = 
{
  { PAPER, SCISSOR, COMPUTER_WON},
  { PAPER, ROCK, PLAYER_WON},
  { PAPER, PAPER, DRAW},
  { PAPER, SPOCK, PLAYER_WON},
  { PAPER, LIZARD, COMPUTER_WON},

  { ROCK, PAPER, COMPUTER_WON},
  { ROCK, SCISSOR, PLAYER_WON},
  { ROCK, ROCK, DRAW},
  { ROCK, SPOCK, COMPUTER_WON},
  { ROCK, LIZARD, PLAYER_WON},

  { SCISSOR, ROCK, COMPUTER_WON},
  { SCISSOR, PAPER, PLAYER_WON},
  { SCISSOR, SCISSOR, DRAW},
  { SCISSOR, LIZARD, PLAYER_WON},
  { SCISSOR, SPOCK, PLAYER_WON},

  { LIZARD, ROCK, COMPUTER_WON},
  { LIZARD, PAPER, PLAYER_WON},
  { LIZARD, SCISSOR, PLAYER_WON},
  { LIZARD, SPOCK, PLAYER_WON},
  { LIZARD, SPOCK, DRAW},

  { SPOCK, LIZARD, COMPUTER_WON},
  { SPOCK, ROCK, PLAYER_WON},
  { SPOCK, PAPER, COMPUTER_WON},
  { SPOCK, SPOCK, DRAW},
  { SPOCK, SCISSOR, PLAYER_WON},
};

#endif