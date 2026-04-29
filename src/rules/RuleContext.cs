using BalatroGodot.Core;
using BalatroGodot.State;

namespace BalatroGodot.Rules;

public sealed class RuleContext
{
    public RuleContext(RunState run, IReadOnlyList<CardState> scoringCards, IReadOnlyList<JokerState> jokers, RandomService random, EventLog log)
    {
        Run = run;
        ScoringCards = scoringCards;
        Jokers = jokers;
        Random = random;
        Log = log;
    }

    public RunState Run { get; }
    public IReadOnlyList<CardState> ScoringCards { get; }
    public IReadOnlyList<JokerState> Jokers { get; }
    public RandomService Random { get; }
    public EventLog Log { get; }
}
