#!/bin/bash

echo "----------------------------------"
echo "Welcome to NBA Wavier Wire Pickups"
echo "----------------------------------"

players=()
player_names=()
player_scores=()

while true
do
  read -r -p "Please enter a player's first and last name (or type 'done' to finish): " player

  if [[ "$player" == "done" ]]; then
    break
  fi

  if [[ " ${players[*]} " == *" $player "* ]]; then
    echo "You already entered that player!"
    continue
  fi

  players+=("$player")
done

echo "Which category would you like to prioritize?"
echo "1. Points"
echo "2. Rebounds"
echo "3. Assists"
echo "4. Steals"
echo "5. Blocks"
echo "6. No Preference"

read -r -p "Enter your choice (1-6): " category

echo "----------------------"
echo "Looking up players..."
echo "----------------------"

for player in "${players[@]}"
do
  encoded_player=${player// /%20}

  player_response=$(curl -s "https://api.bigballsdata.com/v1/players?name=$encoded_player&sport=basketball" \
    -H "Authorization: Bearer $NBA_API_KEY")

  player_id=$(echo "$player_response" | jq -r '.data[0].id // empty')
  returned_name=$(echo "$player_response" | jq -r '.data[0].name // empty')
  lower_returned_name=$(echo "$returned_name" | tr '[:upper:]' '[:lower:]')
  lower_player=$(echo "$player" | tr '[:upper:]' '[:lower:]')

  if [[ -z "$player_id" || "$lower_returned_name" != "$lower_player" ]]; then
    echo "Player not found. Skipping $player."
    continue
  fi
  
  if [[ "$stats" == "null" ]]; then
    echo "No season stats found for $player. Skipping."
    continue
  fi

  stats=$(curl -s "https://api.bigballsdata.com/v1/nba/players/$player_id/season-averages" \
  -H "Authorization: Bearer $NBA_API_KEY" | jq '.data[0]')
    
  gamelog=$(curl -s "https://api.bigballsdata.com/v1/players/$player_id/gamelog?sport=basketball" \
  -H "Authorization: Bearer $NBA_API_KEY")
    
  past5_ppg=$(echo "$gamelog" | jq '[.data[:5][] | .pts] | add / length')
  past5_apg=$(echo "$gamelog" | jq '[.data[:5][] | .ast] | add / length')
  past5_rpg=$(echo "$gamelog" | jq '[.data[:5][] | .reb] | add / length')
  past5_spg=$(echo "$gamelog" | jq '[.data[:5][] | .stl] | add / length')
  past5_bpg=$(echo "$gamelog" | jq '[.data[:5][] | .blk] | add / length')  
  past5_tov=$(echo "$gamelog" | jq '[.data[:5][] | .turnovers] | add / length')

  tov=$(echo "$stats" | jq -r '.turnover')
  ppg=$(echo "$stats" | jq -r '.pts')
  rpg=$(echo "$stats" | jq -r '.reb')
  apg=$(echo "$stats" | jq -r '.ast')
  spg=$(echo "$stats" | jq -r '.stl')
  bpg=$(echo "$stats" | jq -r '.blk')
  
  case "$category" in
    1) season_fp=$(echo "2*$ppg + 1.2*$rpg + 1.5*$apg + 3*$spg + 3*$bpg - $tov" | bc)
       past5_fp=$(echo "2*$past5_ppg + 1.2*$past5_rpg + 1.5*$past5_apg + 3*$past5_spg + 3*$past5_bpg - $past5_tov" | bc) ;;
    2) season_fp=$(echo "$ppg + 2.4*$rpg + 1.5*$apg + 3*$spg + 3*$bpg - $tov" | bc)
       past5_fp=$(echo "$past5_ppg + 2.4*$past5_rpg + 1.5*$past5_apg + 3*$past5_spg + 3*$past5_bpg - $past5_tov" | bc) ;;
    3) season_fp=$(echo "$ppg + 1.2*$rpg + 3*$apg + 3*$spg + 3*$bpg - $tov" | bc)
       past5_fp=$(echo "$past5_ppg + 1.2*$past5_rpg + 3*$past5_apg + 3*$past5_spg + 3*$past5_bpg - $past5_tov" | bc) ;;
    4) season_fp=$(echo "$ppg + 1.2*$rpg + 1.5*$apg + 6*$spg + 3*$bpg - $tov" | bc)
       past5_fp=$(echo "$past5_ppg + 1.2*$past5_rpg + 1.5*$past5_apg + 6*$past5_spg + 3*$past5_bpg - $past5_tov" | bc) ;;
    5) season_fp=$(echo "$ppg + 1.2*$rpg + 1.5*$apg + 3*$spg + 6*$bpg - $tov" | bc)
       past5_fp=$(echo "$past5_ppg + 1.2*$past5_rpg + 1.5*$past5_apg + 3*$past5_spg + 6*$past5_bpg - $past5_tov" | bc) ;;
    6) season_fp=$(echo "$ppg + 1.2*$rpg + 1.5*$apg + 3*$spg + 3*$bpg - $tov" | bc)
       past5_fp=$(echo "$past5_ppg + 1.2*$past5_rpg + 1.5*$past5_apg + 3*$past5_spg + 3*$past5_bpg - $past5_tov" | bc) ;;
  esac
    
  pickup_score=$(echo "scale=2; 0.70*$season_fp + 0.30*$past5_fp" | bc)

  echo ""
  echo "---------------------"
  echo "$player"
  echo "---------------------"
  echo "Season averages vs. Last 5 games"                                     
  echo "PPG: $ppg -> $past5_ppg"                                              
  echo "RPG: $rpg -> $past5_rpg"                                              
  echo "APG: $apg -> $past5_apg"                                              
  echo "SPG: $spg -> $past5_spg"                                              
  echo "BPG: $bpg -> $past5_bpg"
  echo "TOV: $tov -> $past5_tov"
  echo "Season fp $season_fp and past 5 $past5_fp"
  echo "Pickup Score: $pickup_score"

  player_names+=("$player")
  player_scores+=("$pickup_score")
   
done

echo "----------------------"
echo "Waiver Wire Rankings"
echo "----------------------"
rank=0

for i in "${!player_scores[@]}"; do
    echo "${player_scores[$i]} ${player_names[$i]}"
done | sort -rn | while read -r score name; do
    ((rank++))
    printf "%d. %-20s %s\n" "$rank" "$name" "$score"
done
