using BalatroGodot.State;

namespace BalatroGodot.Rules;

public enum PokerHandKind
{
    HighCard,
    Pair,
    TwoPair,
    ThreeOfAKind,
    Straight,
    Flush,
    FullHouse,
    FourOfAKind,
    StraightFlush
}

public sealed record PokerHand(PokerHandKind Kind, int BaseChips, int BaseMult, IReadOnlyList<CardState> ScoringCards);

public sealed class HandEvaluator
{
    public PokerHand Evaluate(IReadOnlyList<CardState> cards)
    {
        if (cards.Count == 0)
        {
            return new PokerHand(PokerHandKind.HighCard, 0, 0, Array.Empty<CardState>());
        }

        var ordered = cards.OrderBy(card => (int)card.Rank).ToList();
        var groups = cards.GroupBy(card => card.Rank).OrderByDescending(group => group.Count()).ThenByDescending(group => group.Key).ToList();
        var isFlush = cards.Select(card => card.Suit).Distinct().Count() == 1 && cards.Count >= 5;
        var isStraight = IsStraight(ordered.Select(card => (int)card.Rank).Distinct().OrderBy(rank => rank).ToList());

        if (isStraight && isFlush) return Hand(PokerHandKind.StraightFlush, 100, 8, cards);
        if (groups[0].Count() == 4) return Hand(PokerHandKind.FourOfAKind, 60, 7, groups[0]);
        if (groups[0].Count() == 3 && groups.Count > 1 && groups[1].Count() >= 2) return Hand(PokerHandKind.FullHouse, 40, 4, groups.Take(2).SelectMany(group => group));
        if (isFlush) return Hand(PokerHandKind.Flush, 35, 4, cards);
        if (isStraight) return Hand(PokerHandKind.Straight, 30, 4, cards);
        if (groups[0].Count() == 3) return Hand(PokerHandKind.ThreeOfAKind, 30, 3, groups[0]);
        if (groups.Count(group => group.Count() == 2) >= 2) return Hand(PokerHandKind.TwoPair, 20, 2, groups.Where(group => group.Count() == 2).Take(2).SelectMany(group => group));
        if (groups[0].Count() == 2) return Hand(PokerHandKind.Pair, 10, 2, groups[0]);

        var highCard = cards.OrderByDescending(card => card.Rank).Take(1).ToList();
        return new PokerHand(PokerHandKind.HighCard, 5, 1, highCard);
    }

    private static PokerHand Hand(PokerHandKind kind, int chips, int mult, IEnumerable<CardState> scoringCards)
    {
        return new PokerHand(kind, chips, mult, scoringCards.ToList());
    }

    private static bool IsStraight(IReadOnlyList<int> ranks)
    {
        if (ranks.Count < 5) return false;
        for (var index = 0; index <= ranks.Count - 5; index++)
        {
            if (ranks[index + 4] - ranks[index] == 4) return true;
        }

        return ranks.Contains(14) && ranks.Contains(2) && ranks.Contains(3) && ranks.Contains(4) && ranks.Contains(5);
    }
}
