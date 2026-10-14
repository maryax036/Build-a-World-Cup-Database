#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

team_values=""
game_values=""

while IFS=, read -r year round winner opponent winner_goals opponent_goals
do
  [[ $year == "year" ]] && continue

  team_values+="${team_values:+,}('$winner'),('$opponent')"
  game_values+="${game_values:+,}($year, '$round', (SELECT team_id FROM teams WHERE name = '$winner'), (SELECT team_id FROM teams WHERE name = '$opponent'), $winner_goals, $opponent_goals)"
done < "$(dirname "$0")/games.csv"

sql="BEGIN;
INSERT INTO teams (name) VALUES $team_values ON CONFLICT (name) DO NOTHING;
INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES $game_values;
COMMIT;"

$PSQL "$sql"
