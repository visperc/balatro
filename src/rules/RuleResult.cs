using BalatroGodot.Core;

namespace BalatroGodot.Rules;

public sealed class RuleResult
{
    public int ChipsDelta { get; set; }
    public float MultDelta { get; set; }
    public float XMultFactor { get; set; } = 1f;
    public List<GameEvent> Events { get; } = new();

    public static RuleResult Empty { get; } = new();
}
