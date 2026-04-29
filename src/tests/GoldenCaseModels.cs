using BalatroGodot.State;

namespace BalatroGodot.Tests;

public sealed record GoldenCase(
    string Name,
    int Seed,
    IReadOnlyList<GoldenJoker> Jokers,
    IReadOnlyList<GoldenCard> PlayedCards,
    GoldenExpected Expected);

public sealed record GoldenJoker(string Id, string RuleId, bool Enabled);

public sealed record GoldenCard(string Id, Suit Suit, Rank Rank);

public sealed record GoldenExpected(string Hand, int ChipsDelta, float MultDelta, float XMultFactor);
