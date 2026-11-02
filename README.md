# NBA-waiver-wire-pickups
A bash tool that analyzes nba waiver wire players and recommends the best players to pick up.

Project Goal
I am going to build a Bash command line tool called NBA wavier wire pick ups, using a NBA stats api to get player data and recent game history. My program aims to compare players' recent performances to their season averages and rank the available players to help fantasy managers choose who they would want to pick up.

MVP Scope
1. Retrieve player stats from NBA api.
2. Get the players that user asked for and get the last 5 games games.
3. Compare the last 5 games to the season averages of the player.
4. Rank and calculate ranking for each player based on scoring system.
5. Rank the players from highest to lowest.
6. Display the final recommendations with player names and relevant stats.

Future plans
1. Add nba schedules to account for easier matchups.
2. Have filters for specific categories like rebounds, assists, and points.
3. Allow users to pick which category they prioritize the most (rank each and find best players for those cases).

Tech Stack
1.
Will be writing the entire thing in Bash.
2. 
-  curl 
- jq
- awk
- sort
- grep
3. 
- JSON files
- Text files
4. 
I will use a NBA stats api to retrieve player stats and I will use curl to retrieves the data in JSON format, then using jq parse that JSON data to then extract the stats needed.
