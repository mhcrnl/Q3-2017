#pragma warning(disable: 4996) // remove if you don't use Visual Studio
#pragma warning(disable: 4127) // conditional expression is constant	in while(true)

#include <iostream>
#include <string>
#include <cstdlib>
//#include <conio.h>
#include <ctime>
#include <algorithm>
#include "Main.h"

using std::cout;
using std::cin;
using std::string;

int main()
{
	try
	{
		srand(static_cast<unsigned int>(time(0)));
		while (true)
		{
			Choice playerChoice = getPlayerChoice();
			if (playerChoice == QUIT)
				break;
			Choice computerChoice = getComputerChoice();
			Result result = getResult(playerChoice, computerChoice);
			showResult(playerChoice, computerChoice, result);
		}
	}
	catch (const std::exception& ex)
	{
		std::cerr << "An error has occured: " << ex.what() << "\n\n";
	}
	pause(); // remove if you don't use Visual Studio
	return EXIT_SUCCESS;
}

Choice getPlayerChoice()
{
	std::string choice;

	while (true)
	{
		cout << "\nEnter your choice (rock, paper, scissor, lizard, spock or quit) ";
		std::getline(cin, choice);
		choice = toLower(choice);

		if (choice == "paper")
			return PAPER;
		else if (choice == "rock")
			return ROCK;
		else if (choice == "scissor")
			return SCISSOR;
		else if (choice == "lizard")
			return LIZARD;
		else if (choice == "spock")
			return SPOCK;
		else if (choice == "quit")
			return QUIT;
	}
}

Choice getComputerChoice()
{
	int num = rand() % 5;

	return Choice(num);
}

Result getResult(Choice player, Choice comp)
{
	auto result = std::find_if(Rules.begin(), Rules.end(), [player, comp](const Rule& rule)
	{
		return rule.comp == comp && rule.player == player;
	});

	if (result == Rules.end())
		throw std::runtime_error("No result found");

	return (*result).result;
}
void showResult(Choice playerChoice, Choice computerChoice, Result result)
{
	cout << "\nYou chose: " << toString(playerChoice);
	cout << "\nComputer chose: " << toString(computerChoice);
	cout << "\nVerdict: ";
	if (result == COMPUTER_WON)
	{
		cout << "You lost";
	}
	else if (result == PLAYER_WON)
	{
		cout << "Congratulation - you won";
	}
	else if (result == DRAW)
	{
		cout << "Draw";
	}
}

string toLower(const string& s)
{
	string retval(s);

	std::for_each(retval.begin(), retval.end(), tolower);

	return retval;
}

string toString(Choice choice)
{
	string choices[] = { "Paper", "Scissor", "Rock", "Lizard", "Spock", "quit" };

	return choices[int(choice)];
}

void pause()
{
	cout << "\n\nPress any key to continue";
//	_getch(); // replace with getchar() if not using Visual Studio
}
