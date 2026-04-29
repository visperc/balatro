using BalatroGodot.State;
using Godot;
using Godot.Collections;

namespace BalatroGodot.Rules;

public sealed class GdScriptRule : IGameRule
{
    private readonly GodotObject _instance;

    public GdScriptRule(string id, RuleTrigger trigger, GodotObject instance)
    {
        Id = id;
        Trigger = trigger;
        _instance = instance;
    }

    public string Id { get; }
    public RuleTrigger Trigger { get; }
    public RuleScope Scope { get; } = RuleScope.Joker;

    public RuleResult Execute(RuleContext context)
    {
        var payload = new Dictionary
        {
            ["run"] = ToRunDictionary(context.Run),
            ["scoring_cards"] = ToCardsArray(context.ScoringCards),
            ["jokers"] = ToJokersArray(context.Jokers),
            ["seed"] = context.Random.Seed
        };

        var raw = _instance.Call("execute", payload);
        if (raw.VariantType != Variant.Type.Dictionary)
        {
            return RuleResult.Empty;
        }

        return FromDictionary(raw.AsGodotDictionary());
    }

    private static Dictionary ToRunDictionary(RunState run)
    {
        return new Dictionary
        {
            ["run_id"] = run.RunId,
            ["ante"] = run.Ante,
            ["round"] = run.Round,
            ["money"] = run.Money,
            ["score"] = run.Score
        };
    }

    private static Array<Dictionary> ToCardsArray(IEnumerable<CardState> cards)
    {
        var result = new Array<Dictionary>();
        foreach (var card in cards)
        {
            result.Add(new Dictionary
            {
                ["id"] = card.Id,
                ["suit"] = card.Suit.ToString().ToLowerInvariant(),
                ["rank"] = card.Rank.ToString().ToLowerInvariant(),
                ["rank_value"] = (int)card.Rank,
                ["is_scoring"] = card.IsScoring
            });
        }

        return result;
    }

    private static Array<Dictionary> ToJokersArray(IEnumerable<JokerState> jokers)
    {
        var result = new Array<Dictionary>();
        foreach (var joker in jokers)
        {
            result.Add(new Dictionary
            {
                ["id"] = joker.Id,
                ["rule_id"] = joker.RuleId,
                ["enabled"] = joker.Enabled
            });
        }

        return result;
    }

    private static RuleResult FromDictionary(Dictionary dictionary)
    {
        return new RuleResult
        {
            ChipsDelta = GetInt(dictionary, "chips_delta"),
            MultDelta = GetFloat(dictionary, "mult_delta"),
            XMultFactor = dictionary.ContainsKey("xmult_factor") ? GetFloat(dictionary, "xmult_factor") : 1f
        };
    }

    private static int GetInt(Dictionary dictionary, string key)
    {
        return dictionary.ContainsKey(key) ? dictionary[key].AsInt32() : 0;
    }

    private static float GetFloat(Dictionary dictionary, string key)
    {
        return dictionary.ContainsKey(key) ? (float)dictionary[key].AsDouble() : 0f;
    }
}

public sealed class GdScriptRuleLoader
{
    public IGameRule Load(string rulePath)
    {
        var script = ResourceLoader.Load<Script>(rulePath);
        if (script is null)
        {
            throw new FileNotFoundException("Rule script not found.", rulePath);
        }

        var instance = new RefCounted();
        instance.SetScript(script);
        var id = instance.Call("get_id").AsString();
        var triggerName = instance.Call("get_trigger").AsString();
        if (!Enum.TryParse<RuleTrigger>(triggerName, out var trigger))
        {
            throw new InvalidOperationException($"Unknown rule trigger '{triggerName}' in {rulePath}.");
        }

        return new GdScriptRule(id, trigger, instance);
    }
}
