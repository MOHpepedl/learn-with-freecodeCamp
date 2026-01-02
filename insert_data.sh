#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi
echo 
# Do not change code above this line. Use the PSQL variable above to query your database.

# إفراغ الجداول الحالية
echo $($PSQL "TRUNCATE TABLE games, teams")

# قراءة ملف CSV
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # تخطي السطر الأول (العناوين)
  if [[ $YEAR != "year" ]]
  then
    # إضافة الفريق الفائز إذا لم يكن موجوداً
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    
    if [[ -z $WINNER_ID ]]
    then
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
      then
        WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
      fi
    fi

    # إضافة الفريق الخصم إذا لم يكن موجوداً
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    
    if [[ -z $OPPONENT_ID ]]
    then
      INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]
      then
        OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
      fi
    fi

    # إضافة المباراة
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
  fi
done
