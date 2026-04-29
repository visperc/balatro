namespace BalatroGodot.Rules;

public interface IGameRule
{
    string Id { get; }
    RuleTrigger Trigger { get; }
    RuleScope Scope { get; }
    RuleResult Execute(RuleContext context);
}
