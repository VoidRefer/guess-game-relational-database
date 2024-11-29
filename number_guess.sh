#!/bin/bash 
# randomly generate a number that users have to guess

PSQL="psql --username=postgres --dbname=number_guess -t --no-align -c"

GAME() {
    NUMBER_OF_GUESSES=0
    while true 
    do
        read GUESS
        ((NUMBER_OF_GUESSES++))

        if ! [[ $GUESS =~ ^[0-9]+$ ]]
        then
            echo "That is not an integer, guess again:"
        elif [[ $GUESS -lt $RANDOM_NUM ]]
        then    
            echo "It's higher than that, guess again."
        elif [[ $GUESS -gt $RANDOM_NUM ]]
        then    
            echo "It's lower than that, guess again."
        else
            echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUM."
            # Update user stats in the database
            USER_STATS_INSERT=$($PSQL "UPDATE users SET games_played = games_played + 1, best_game = LEAST(best_game, $NUMBER_OF_GUESSES) WHERE username='$USERNAME';")
            
        fi
    done
    
}

RANDOM_NUM=$((1 + $RANDOM % 1000))

echo -e "\nEnter your username:"
read USERNAME

# Check if the user exists in the database
USER_DATA=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username='$USERNAME';")

if [[ -z $USER_DATA ]]
then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    # Insert new user to database
    USER_INSERT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
else
    echo $USER_DATA | while IFS="|" read USERNAME GAMES_PLAYED BEST_GAME 
    do  
      echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    done
fi

echo -e "\nGuess the secret number between 1 and 1000:"
GAME

