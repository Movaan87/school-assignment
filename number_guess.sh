#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
MIN=1
MAX=1000
SECRET_NUMBER=$(($RANDOM % ($MAX - $MIN + 1) + $MIN))
echo -e "\n~~~~~ Number Guessing Game ~~~~~\n"
echo -e "\nEnter your username:"
read USERNAME
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")
if [[ -z $USER_ID ]]
then
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  USER_INSERT_RESULT=$($PSQL "INSERT INTO users (username) VALUES ('$USERNAME');")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")
else
  IFS="|" read GAMES_PLAYED BEST_GAME <<< $($PSQL "SELECT COUNT(number_of_guesses) AS games_played, MIN(number_of_guesses) AS best_game FROM games WHERE user_id=$USER_ID;") # 
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
echo -e "\nGuess the secret number between $MIN and $MAX: $SECRET_NUMBER"
read USER_GUESS
NUMBER_OF_GUESSES=1
while [ $USER_GUESS != $SECRET_NUMBER ]
do
  if [[ $USER_GUESS =~ ^[0-9]+$ ]]
  then
    if [[ $USER_GUESS > $SECRET_NUMBER ]]
    then
      echo -e "\nIt's lower than that, guess again:"
    else
      echo -e "\nIt's higher than that, guess again:"
    fi
  else
    echo -e "\nThat is not an integer, guess again:"
  fi
  read USER_GUESS
  ((NUMBER_OF_GUESSES++))
done
INSERT_GAME_RESULT=$($PSQL "INSERT INTO games (user_id, number_of_guesses) VALUES ($USER_ID, $NUMBER_OF_GUESSES);")
echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
