namespace BalatroGodot.State;

public sealed class RunState
{
    public string RunId { get; init; } = Guid.NewGuid().ToString("N");
    public int Ante { get; set; } = 1;
    public int Round { get; set; } = 1;
    public int Money { get; set; }
    public int Score { get; set; }
    public List<CardState> Deck { get; } = new();
    public List<CardState> Hand { get; } = new();
    public List<JokerState> Jokers { get; } = new();
}
