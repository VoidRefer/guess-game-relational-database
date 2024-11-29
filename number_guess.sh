#!/bin/bash 
# randomly generate a number that users have to guess

PSQL="psql --username=postgres --dbname=number_guess -t --no-align -c"

RANDOM_NUM=$((1 + $RANDOM % 1000))

echo -e "\nEnter your username:"
read USERNAME

# Check if the user exists in the database
USER_DATA=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username='$USERNAME';")

if [[ -z $USER_DATA ]]
then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    # Insert new user to database
    USER_INSERT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME'))")
else
    echo $USER_DATA | while IFS="|" read USERNAME GAMES_PLAYED BEST_GAME 
    do  
      echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    done
fi