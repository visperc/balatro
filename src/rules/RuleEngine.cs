using BalatroGodot.Core;

namespace BalatroGodot.Rules;

public sealed class ScriptRule : IGameRule
{
    private readonly Func<RuleContext, RuleResult> _execute;

    public ScriptRule(string id, RuleTrigger trigger, Func<RuleContext, RuleResult> execute, RuleScope scope = RuleScope.Global)
    {
        Id = id;
        Trigger = trigger;
        Scope = scope;
        _execute = execute;
    }

    public string Id { get; }
    public RuleTrigger Trigger { get; }
    public RuleScope Scope { get; }

    public RuleResult Execute(RuleContext context) => _execute(context);
}

public sealed class RuleEngine
{
    private readonly Dictionary<RuleTrigger, List<IGameRule>> _rules = new();

    public void Register(IGameRule rule)
    {
        if (!_rules.TryGetValue(rule.Trigger, out var rules))
        {
            rules = new List<IGameRule>();
            _rules[rule.Trigger] = rules;
        }

        rules.RemoveAll(existing => existing.Id == rule.Id);
        rules.Add(rule);
    }

    public RuleExecutionResult Execute(RuleTrigger trigger, RuleContext context)
    {
        var aggregate = new RuleExecutionResult();
        if (!_rules.TryGetValue(trigger, out var rules))
        {
            return aggregate;
        }

        foreach (var rule in rules)
        {
            if (!ShouldExecute(rule, context)) continue;

            var result = rule.Execute(context);
            aggregate.Chips += result.ChipsDelta;
            aggregate.Mult += result.MultDelta;
            aggregate.XMult *= result.XMultFactor;

            foreach (var gameEvent in result.Events)
            {
                aggregate.Events.Add(gameEvent);
            }

            context.Log.Add("rule.executed", rule.Id, new Dictionary<string, object?>
            {
                ["trigger"] = trigger.ToString(),
                ["chips_delta"] = result.ChipsDelta,
                ["mult_delta"] = result.MultDelta,
                ["xmult_factor"] = result.XMultFactor
            });
        }

        return aggregate;
    }

    private static bool ShouldExecute(IGameRule rule, RuleContext context)
    {
        if (rule.Scope == RuleScope.Global) return true;
        return context.Jokers.Any(joker => joker.Enabled && joker.RuleId == rule.Id);
    }
}

public sealed class RuleExecutionResult
{
    public int Chips { get; set; }
    public float Mult { get; set; }
    public float XMult { get; set; } = 1f;
    public List<GameEvent> Events { get; } = new();
}
