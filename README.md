# Balatro Godot Logic Prototype

Godot 4.6 Mono project scaffold for a Balatro-like logic system.

## Current Playable Prototype

The main scene now contains a minimal playable scoring loop:

- Builds and shuffles a 52-card deck.
- Draws an 8-card hand.
- Lets the player select up to 5 cards.
- Supports play hand and discard actions.
- Evaluates poker hands: high card, pair, two pair, three of a kind, straight, flush, full house, four of a kind, straight flush.
- Scores base chips/mult, card chip values, additive Joker effects, and X-mult Joker effects.
- Shows score, hands left, discards left, deck count, active Jokers, and score log.

Implemented Joker rule examples:

- Greedy Joker: +4 mult for each scoring heart.
- Flat Bonus Joker: +10 chips when a hand is played.
- Pair Mult Joker: +8 mult on Pair.
- Face Chips Joker: +10 chips per scoring J/Q/K.
- Flush XMult Joker: x2 on Flush or Straight Flush.

## Structure

- `src/core`: C# runtime services and bootstrap foundation.
- `src/state`: strongly typed run/card/joker state foundation.
- `src/rules`: C# hand evaluation, rule interfaces, C# to GDScript bridge foundation.
- `scripts/gameplay`: current GDScript playable prototype runtime.
- `scripts/autoload`: Godot startup scripts.
- `content/config`: built-in content catalogs.
- `content/rules`: hot-updatable GDScript Joker rules.
- `content/specs`: SDD specifications.
- `content/tests/golden`: golden behavior cases.

## Run

Open this folder with Godot 4.6 Mono and run the main scene:

```powershell
godot --path D:\workspace\Balatro_godot
```

## Validate

```powershell
dotnet build
godot --path D:\workspace\Balatro_godot --headless --quit-after 5
godot --path D:\workspace\Balatro_godot --headless --script res://scripts/tests/smoke_balatro_run.gd
```