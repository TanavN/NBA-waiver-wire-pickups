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
    
    stats=$(curl -s "https://api.bigballsdata.com/v1/nba/players/$player_id/season-averages" \
    -H "Authorization: Bearer $NBA_API_KEY" | jq '.data[0]')
    
    gamelog=$(curl -s "https://api.bigballsdata.com/v1/players/$player_id/gamelog?sport=basketball" \
    -H "Authorization: Bearer $NBA_API_KEY")

    past5_ppg=$(echo "$gamelog" | jq '[.data[:5][] | .pts] | add / length')
    past5_apg=$(echo "$gamelog" | jq '[.data[:5][] | .ast] | add / length')
    past5_rpg=$(echo "$gamelog" | jq '[.data[:5][] | .reb] | add / length')
    past5_spg=$(echo "$gamelog" | jq '[.data[:5][] | .stl] | add / length')
    past5_bpg=$(echo "$gamelog" | jq '[.data[:5][] | .blk] | add / length')  

    ppg=$(echo "$stats" | jq -r '.pts')
    rpg=$(echo "$stats" | jq -r '.reb')
    apg=$(echo "$stats" | jq -r '.ast')
    spg=$(echo "$stats" | jq -r '.stl')
    bpg=$(echo "$stats" | jq -r '.blk')
    
    echo ""                                                                     
    echo "Season averages vs. Last 5 games"                                     
    echo "PPG: $ppg -> $past5_ppg"                                              
    echo "RPG: $rpg -> $past5_rpg"                                              
    echo "APG: $apg -> $past5_apg"                                              
    echo "SPG: $spg -> $past5_spg"                                              
    echo "BPG: $bpg -> $past5_bpg"

done
