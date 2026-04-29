using System.Text.Json;

namespace BalatroGodot.Data;

public sealed record JokerDefinition(
    string Id,
    string Name,
    string Rarity,
    int Cost,
    string Script,
    string[] Triggers);

public sealed record ContentCatalog(
    string Version,
    IReadOnlyList<JokerDefinition> Jokers);

public sealed class ContentLoader
{
    private readonly JsonSerializerOptions _jsonOptions = new(JsonSerializerDefaults.Web)
    {
        PropertyNameCaseInsensitive = true
    };

    public ContentCatalog LoadFromDirectory(string rootPath)
    {
        var jokersPath = Path.Combine(rootPath, "config", "jokers.json");
        if (!File.Exists(jokersPath))
        {
            throw new FileNotFoundException("Missing joker catalog.", jokersPath);
        }

        var jokers = JsonSerializer.Deserialize<List<JokerDefinition>>(File.ReadAllText(jokersPath), _jsonOptions)
            ?? throw new InvalidOperationException("Failed to parse jokers.json.");

        return new ContentCatalog("builtin", jokers);
    }
}
