#!/bin/bash

echo "----------------------------------"
echo "Welcome to NBA Wavier Wire Pickups"
echo "----------------------------------"

players=()

while true
do
  read -r -p "Please enter a player's first and last name (or type 'done' to finish): " player

  if [[ "$player" == "done" ]]; then
    break
  fi

  players+=("$player")
done
