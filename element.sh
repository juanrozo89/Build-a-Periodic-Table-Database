#!/bin/bash
# Program to extract information from elements in the periodic table
# 2022 Juan Rozo

PSQL="psql --username=freecodecamp --dbname=periodic_table --tuples-only -c" # psql for querying database 
if [[ -z $1 ]] # no input for query
then 
  echo Please provide an element as an argument.
else # existing argument
  if [[ $1 =~ ^[0-9]+$ ]] # input atomic number
  then
    ELEMENT=$($PSQL "SELECT * FROM elements WHERE atomic_number=$1;") # query by atomic number
  elif [[ $1 =~ ^[A-Z][a-z]{0,2}$ ]] # input symbol
  then
    ELEMENT=$($PSQL "SELECT * FROM elements WHERE symbol='$1';") # query by symbol
  elif [[ $1 =~ ^[A-Za-z]+$ ]] # input name
  then
    ELEMENT=$($PSQL "SELECT * FROM elements WHERE name='$1';") # query by name
  else # invalid input
    echo "Ivalid input."
    exit
  fi
  if [[ -z $ELEMENT ]] # no matching element found
  then 
    echo "I could not find that element in the database."
  else # element found
    echo $ELEMENT | while read ATOMIC_NUMBER BAR SYMBOL BAR NAME
    do
      TYPE=$($PSQL "SELECT type FROM properties JOIN elements USING(atomic_number) JOIN types USING(type_id) WHERE atomic_number=$ATOMIC_NUMBER;")
      ATOMIC_MASS=$($PSQL "SELECT atomic_mass FROM properties JOIN elements USING(atomic_number) JOIN types USING(type_id) WHERE atomic_number=$ATOMIC_NUMBER;")
      MELTING_POINT=$($PSQL "SELECT melting_point_celsius FROM properties JOIN elements USING(atomic_number) JOIN types USING(type_id) WHERE atomic_number=$ATOMIC_NUMBER;")
      BOILING_POINT=$($PSQL "SELECT boiling_point_celsius FROM properties JOIN elements USING(atomic_number) JOIN types USING(type_id) WHERE atomic_number=$ATOMIC_NUMBER;")
      # provide information about the element:
      echo "The element with atomic number $ATOMIC_NUMBER is "$NAME" ("$SYMBOL"). It's a"$TYPE", with a mass of"$ATOMIC_MASS" amu. "$NAME" has a melting point of"$MELTING_POINT" celsius and a boiling point of"$BOILING_POINT" celsius."
    done
  fi
fi
