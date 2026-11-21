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

echo "----------------------"
echo "Looking up players..."
echo "----------------------"

for player in "${players[@]}"
do
    encoded_player=${player// /%20}

    player_id=$(curl -s "https://api.bigballsdata.com/v1/players?name=$encoded_player&sport=basketball" \
        -H "Authorization: Bearer $NBA_API_KEY" | jq -r '.data[0].id')

    echo "$player: $player_id"

    stats=$(curl -s "https://api.bigballsdata.com/v1/players/$player_id/stats?sport=basketball" \
    -H "Authorization: Bearer $NBA_API_KEY" | jq -r '.data')

    echo "$stats" | jq '{gp, ppg, rpg, apg, spg, bpg}'
done
