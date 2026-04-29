namespace BalatroGodot.Core;

public sealed class RandomService
{
    private readonly Random _random;

    public RandomService(int seed)
    {
        Seed = seed;
        _random = new Random(seed);
    }

    public int Seed { get; }

    public int Next(int minInclusive, int maxExclusive) => _random.Next(minInclusive, maxExclusive);

    public double NextDouble() => _random.NextDouble();
}
