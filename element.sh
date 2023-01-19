#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

ATOMIC_NUMBER_GIVEN() {
  SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number = $ATOMIC_NUMBER")
  ELEMENT=$($PSQL "SELECT name FROM elements WHERE atomic_number = $ATOMIC_NUMBER")
}

SYMBOL_GIVEN() {
  ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$SYMBOL'")
  ELEMENT=$($PSQL "SELECT name FROM elements WHERE symbol = '$SYMBOL'")
}

ELEMENT_NAME_GIVEN() {
  ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name = '$ELEMENT'")
  SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE name = '$ELEMENT'")
}

OUTPUT() {
  if [[ -z $ATOMIC_NUMBER ]] || [[ -z $SYMBOL ]] || [[ -z $ELEMENT ]]
  then
    echo -e "I could not find that element in the database."
  else
    TYPE=$($PSQL "SELECT type FROM types FULL JOIN properties USING(type_id) WHERE atomic_number = $ATOMIC_NUMBER")
    TYPE_FORMATTED=$(echo $TYPE | sed -e 's/[[:space:]]*$//')
    SYMBOL_FORMATTED=$(echo $SYMBOL | sed -e 's/[[:space:]]*$//')
    ATOMIC_MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
    MELTING_POINT=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
    BOILING_POINT=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
    echo -e "The element with atomic number" $ATOMIC_NUMBER "is" $ELEMENT" ("$SYMBOL_FORMATTED"). It's a" $TYPE_FORMATTED", with a mass of" $ATOMIC_MASS "amu." $ELEMENT "has a melting point of" $MELTING_POINT "celsius and a boiling point of" $BOILING_POINT" celsius."
  fi
}

#It\'s a nonmetal, with a mass of 1.008 amu. Hydrogen has a melting point of -259.1 celsius and a boiling point of -252.9 celsius.

if [[ -z $1 ]]
then
  echo -e "Please provide an element as an argument."
elif [[ $1 =~ [0-9]+ ]]
then
  ATOMIC_NUMBER=$1
  ATOMIC_NUMBER_GIVEN
  OUTPUT
elif [[ $1 =~ ^[a-zA-Z]{0,3}$ ]]
then
  SYMBOL=$1
  SYMBOL_GIVEN
  OUTPUT
elif [[ $1 =~ ^[a-zA-Z]{4,100}$ ]]
then
  ELEMENT=$1
  ELEMENT_NAME_GIVEN
  OUTPUT
fi
