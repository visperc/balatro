namespace BalatroGodot.Core;

public sealed record GameEvent(string Type, string SourceId, IReadOnlyDictionary<string, object?> Payload);

public sealed class EventLog
{
    private readonly List<GameEvent> _events = new();

    public IReadOnlyList<GameEvent> Events => _events;

    public void Add(string type, string sourceId, IReadOnlyDictionary<string, object?>? payload = null)
    {
        _events.Add(new GameEvent(type, sourceId, payload ?? new Dictionary<string, object?>()));
    }
}
