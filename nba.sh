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
    
    gamelog=$(curl -s "https://api.bigballsdata.com/v1/players/$player_id/gamelog?sport=basketball" \
    -H "Authorization: Bearer $NBA_API_KEY")

    past5_ppg=$(echo "$gamelog" | jq '[.data[:5][] | .pts] | add / length')
    past5_apg=$(echo "$gamelog" | jq '[.data[:5][] | .ast] | add / length')
    past5_rpg=$(echo "$gamelog" | jq '[.data[:5][] | .reb] | add / length')
    past5_spg=$(echo "$gamelog" | jq '[.data[:5][] | .stl] | add / length')
    past5_bpg=$(echo "$gamelog" | jq '[.data[:5][] | .blk] | add / length')

    echo "Last 5 games averages:"
    echo "PPG: $past5_ppg | RPG: $past5_rpg | APG: $past5_apg | SPG: $past5_spg | BPG: $past5_bpg"

    ppg=$(echo "$stats" | jq -r '.ppg')
    rpg=$(echo "$stats" | jq -r '.rpg')
    apg=$(echo "$stats" | jq -r '.apg')
    spg=$(echo "$stats" | jq -r '.spg')
    bpg=$(echo "$stats" | jq -r '.bpg')

done
