#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

$($PSQL "ALTER TABLE teams ALTER COLUMN team_id SET NOT NULL;")
$($PSQL "ALTER TABLE teams ALTER COLUMN name SET NOT NULL;")

# Alter games table columns to NOT NULL
$($PSQL "ALTER TABLE games ALTER COLUMN game_id SET NOT NULL;")
$($PSQL "ALTER TABLE games ALTER COLUMN year SET NOT NULL;")
$($PSQL "ALTER TABLE games ALTER COLUMN opponent_goals SET NOT NULL;")
$($PSQL "ALTER TABLE games ALTER COLUMN winner_goals SET NOT NULL;")
# Truncate tables to start with a clean slate
echo $($PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY")

# Read games.csv and insert data
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Skip the header row
  if [[ $YEAR != "year" ]]
  then
    # Get the winner_id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    # If not found
    if [[ -z $WINNER_ID ]]
    then
      # Insert winner
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      # Get new winner_id
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi
    
    # Get the opponent_id
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    # If not found
    if [[ -z $OPPONENT_ID ]]
    then
      # Insert opponent
      INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      # Get new opponent_id
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi
    
    # Insert game
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
  fi
done