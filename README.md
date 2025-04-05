<div align="center">
  <img src="https://circleci.com/gh/nicolaslechenic/poker_arena/tree/develop.svg?style=svg" alt="Circleci" />

  <a href="https://codeclimate.com/github/nicolaslechenic/poker_arena/maintainability"><img src="https://api.codeclimate.com/v1/badges/5ca029ec4c9615869359/maintainability" /></a>
</div>

# Poker Arena API (Work in Progress)

Poker Arena is an API that allows bots to play poker against each other. The API follows the rules of [Texas Hold'em no limit](https://www.pokernews.com/poker-rules/texas-holdem.htm).

## API Usage for Bots

### Creating a Player

To create a player, send a POST request to `/api/players`:

```
POST /api/players
{
  "pseudo": "YourBotName"
}
```

```curl
curl -H 'Content-Type: application/json' -d '{ "pseudo": "JohnDoe" }' -X POST http://localhost:3000/api/players
```

Response:
```json
{
  "status": 200,
  "token": "player_token_here"
}
```

Save this token as it will be used for all future requests.

### Available Tables

The API automatically creates tables with the following names:
- arrakis
- azuria
- balamb
- gnomeregan
- hyrule
- midgar
- tatooine
- terminus
- winterfell

You can get a list of all tables by sending a GET request to `/api/tables`:

```
GET /api/tables
```

Response:
```json
{
  "tables": [
    {
      "name": "Tatooine",
      "players": []
    },
    {
      "name": "Harrenhal",
      "players": []
    },
    ...
  ]
}
```

### Joining a Table

To join a table, send a POST request to `/api/tables/:name/join` with one of the available table names:

```
POST /api/tables/Tatooine/join
{
  "token": "player_token_here"
}
```

Response:
```json
{
  "status": 200
}
```

You can also leave a table by sending a POST request to `/api/tables/:name/leave`:

```
POST /api/tables/Tatooine/leave
{
  "token": "player_token_here"
}
```

Response:
```json
{
  "status": 200
}
```

### Starting a Game

To start a game (when at least 2 players are present), send a POST request to `/api/tables/:name/start`:

```
POST /api/tables/Alpha/start
{
  "token": "player_token_here"
}
```

Response:
```json
{
  "status": 200,
  "message": "Game started"
}
```

### Getting Game State

To get the current state of the game as a player, send a GET request to `/api/tables/:name/state`:

```
GET /api/tables/Tatooine/state?token=player_token_here
```

Response (when a game is in progress):
```json
{
  "status": 200,
  "state": "active",
  "game": {
    "status": "preflop",
    "pot": 1.5,
    "current_player": {
      "pseudo": "YourBotName",
      "position": 0
    },
    "board": {
      "flop": null,
      "turn": null,
      "river": null
    },
    "players": [
      {
        "pseudo": "YourBotName",
        "stack": 100,
        "position": 0,
        "cards": ["As", "Kh"]
      },
      {
        "pseudo": "OtherBot",
        "stack": 100,
        "position": 1
      }
    ]
  }
}
```

Response (when no game is in progress):
```json
{
  "status": 200,
  "state": "waiting",
  "message": "No game in progress"
}
```

### Spectating a Game

To spectate a game (view the game state without seeing player cards), send a GET request to `/api/tables/:name/spectate`:

```
GET /api/tables/Tatooine/spectate
```

Response (when a game is in progress):
```json
{
  "status": 200,
  "state": "active",
  "game": {
    "status": "preflop",
    "pot": 1.5,
    "current_player": {
      "pseudo": "Player1",
      "position": 0
    },
    "board": {
      "flop": ["7h", "8d", "Jc"],
      "turn": "Qs",
      "river": null
    },
    "players": [
      {
        "pseudo": "Player1",
        "stack": 100,
        "position": 0
      },
      {
        "pseudo": "Player2",
        "stack": 100,
        "position": 1
      }
    ]
  }
}
```

Response (when no game is in progress):
```json
{
  "status": 200,
  "state": "waiting",
  "message": "No game in progress"
}
```

### Performing an Action

To perform an action (bet, call, raise, fold), send a POST request to `/api/tables/:name/action`:

```
POST /api/tables/Alpha/action
{
  "token": "player_token_here",
  "action_type": "call",
  "value": 1.0
}
```

Response:
```json
{
  "status": 200,
  "message": "Action processed"
}
```

Available action types:
- `bet`: Place a bet (when no bet has been made yet)
- `call`: Match the current bet
- `raise`: Increase the current bet
- `fold`: Forfeit the hand

## Bot Implementation Tips

1. **Poll the game state regularly** to check if it's your turn to act.
2. **Check the current_player field** in the game state to see if it's your turn.
3. **Analyze the board and your cards** to make decisions.
4. **Track the pot and player stacks** to calculate pot odds.
5. **Handle errors gracefully** by checking the status code and error messages.

## Running Locally

To run Poker Arena locally for testing:

1. **Clone the repository**
   ```
   git clone https://github.com/nicolaslechenic/poker_arena.git
   cd poker_arena
   ```

2. **Install dependencies**
   ```
   bundle install
   ```

3. **Run the server**
   ```
   rackup -p 3000
   ```

4. **Access the API**
   The API will be available at `http://localhost:3000`

## Testing and Code Coverage

Poker Arena uses RSpec for testing and SimpleCov for code coverage analysis.

1. **Run the tests**
   ```
   bundle exec rspec
   ```

2. **View code coverage report**
   
   After running the tests, SimpleCov generates a coverage report in the `coverage` directory. Open `coverage/index.html` in your browser to view the report:
   
   ```
   open coverage/index.html
   ```
   
   The report shows:
   - Overall code coverage percentage
   - Coverage by file and line
   - Grouped coverage by component type (Controllers, Models, etc.)
   - Lines that are not covered by tests

3. **Improving coverage**
   
   To improve code coverage:
   - Write tests for uncovered files
   - Add test cases for uncovered lines
   - Focus on critical components like controllers and use cases

## Project Status

This project is currently a work in progress. The core functionality is implemented, but some features are still under development:

- Split pots for tied hands
- Side pots for all-in situations

Feel free to contribute to the project by submitting pull requests or reporting issues.
