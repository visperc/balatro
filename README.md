# Balatro Godot Logic Prototype

Godot 4 C# project scaffold for a Balatro-like logic system.

## Structure
- `src/core`: runtime services and bootstrap.
- `src/state`: strongly typed run/card/joker state.
- `src/rules`: hand evaluation, rule interfaces, C# to GDScript bridge.
- `src/data`: JSON content loading.
- `src/hotupdate`: manifest validation and version selection.
- `content/config`: built-in content catalogs.
- `content/rules`: hot-updatable GDScript rules.
- `content/specs`: SDD specifications.
- `content/tests/golden`: golden behavior cases.

## Run
Open this folder with Godot 4 .NET, build the C# project, then run `scenes/Main.tscn`.
