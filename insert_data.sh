#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=worldcup --no-align --tuples-only -c"

# إفراغ الجداول
echo $($PSQL "TRUNCATE teams, games RESTART IDENTITY")

# قراءة ملف CSV
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # تخطي السطر الأول
  if [[ $YEAR != "year" ]]
  then
    # الحصول على/إضافة الفريق الفائز
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    if [[ -z $WINNER_ID ]]
    then
      INSERT_WINNER=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER') RETURNING team_id")
      WINNER_ID=$(echo $INSERT_WINNER | sed 's/[^0-9]*//g')
    fi

    # الحصول على/إضافة الفريق الخصم
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    if [[ -z $OPPONENT_ID ]]
    then
      INSERT_OPPONENT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT') RETURNING team_id")
      OPPONENT_ID=$(echo $INSERT_OPPONENT | sed 's/[^0-9]*//g')
    fi

    # إضافة المباراة
    INSERT_GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
  fi
done
