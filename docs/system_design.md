# System Design

This project uses a mixed Godot architecture:

- C# owns stable runtime services, state, hand evaluation, hot update selection, and rule dispatch.
- GDScript owns hot-updatable gameplay rules.
- JSON owns content catalogs and balancing data.
- Specs and golden cases define behavior before implementation.

## Hot Update Boundary
Hot update packages may replace files under `content/config` and `content/rules`. C# source, Godot scenes, engine version, and exported binaries are release-bound.

## Content Package Shape
```text
manifest.json
config/jokers.json
rules/jokers/*.gd
```

The runtime validates manifest compatibility and hashes before selecting a package. Invalid updates are skipped and built-in content is used.

## Development Loop
1. Write or update a spec under `content/specs`.
2. Add a golden input under `content/tests/golden`.
3. Implement JSON and GDScript rule changes.
4. Run Godot and verify the event log / sample output.
5. Add C# tests once the project has a test runner package installed.
