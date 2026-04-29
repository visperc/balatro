using BalatroGodot.Core;
using BalatroGodot.Data;
using BalatroGodot.HotUpdate;
using BalatroGodot.Rules;
using BalatroGodot.State;
using Godot;

namespace BalatroGodot.Core;

public partial class GameBootstrap : Node
{
    private const string BaseVersion = "0.1.0";

    public override void _Ready()
    {
        var contentRoot = ResolveContentRoot();
        var catalog = new ContentLoader().LoadFromDirectory(ProjectSettings.GlobalizePath(contentRoot));
        var engine = new RuleEngine();
        var scriptLoader = new GdScriptRuleLoader();

        foreach (var joker in catalog.Jokers)
        {
            engine.Register(scriptLoader.Load($"{contentRoot}/{joker.Script}"));
        }

        var run = new RunState();
        run.Jokers.Add(new JokerState("joker_greedy", "joker_greedy"));

        var playedCards = new[]
        {
            new CardState("heart_a", Suit.Hearts, Rank.Ace),
            new CardState("heart_k", Suit.Hearts, Rank.King)
        };

        var hand = new HandEvaluator().Evaluate(playedCards);
        var log = new EventLog();
        var context = new RuleContext(run, hand.ScoringCards, run.Jokers, new RandomService(12345), log);
        var result = engine.Execute(RuleTrigger.OnCardScored, context);
        GD.Print($"Sample score path: {hand.Kind}, chips={hand.BaseChips + result.Chips}, mult={hand.BaseMult + result.Mult}, xmult={result.XMult}");
    }

    private static string ResolveContentRoot()
    {
        var builtinRoot = "res://content";
        var userHotfixRoot = ProjectSettings.GlobalizePath("user://hotfix");
        var selected = new ContentVersionSelector().SelectContentRoot(ProjectSettings.GlobalizePath(builtinRoot), userHotfixRoot, BaseVersion);
        return selected == ProjectSettings.GlobalizePath(builtinRoot) ? builtinRoot : selected;
    }
}
