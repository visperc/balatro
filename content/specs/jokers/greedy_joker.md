# Greedy Joker Spec

## Intent
When a scoring card is hearts, this Joker adds +4 mult for each scoring hearts card.

## Trigger
`OnCardScored`

## Inputs
- Current scoring cards.
- Current run state.
- Joker must be present and enabled by the C# rule registry before execution.

## Acceptance Cases
| Case | Scoring Cards | Expected Chips Delta | Expected Mult Delta | Expected XMult |
| --- | --- | ---: | ---: | ---: |
| No hearts | AS, KC | 0 | 0 | 1.0 |
| One heart | AH, KC | 0 | 4 | 1.0 |
| Two hearts | AH, KH | 0 | 8 | 1.0 |

## Regression Notes
This rule must not mutate run state. The only allowed output is score deltas and events.
