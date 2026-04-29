extends RefCounted
class_name BalatroRun

const SUITS := ["Spades", "Hearts", "Clubs", "Diamonds"]
const RANKS := [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
const HAND_LIMIT := 8
const PLAY_LIMIT := 5
const TARGET_SCORE := 300

var rng := RandomNumberGenerator.new()
var deck: Array[Dictionary] = []
var hand: Array[Dictionary] = []
var discard_pile: Array[Dictionary] = []
var selected_ids: Array[String] = []
var score := 0
var hands_left := 4
var discards_left := 3
var round_index := 1
var jokers: Array[Dictionary] = []
var joker_rules: Dictionary = {}
var last_result: Dictionary = {}

func start(seed: int = 12345) -> void:
	rng.seed = seed
	score = 0
	hands_left = 4
	discards_left = 3
	round_index = 1
	selected_ids.clear()
	discard_pile.clear()
	jokers = [
		{"id": "joker_greedy", "name": "Greedy Joker", "rule_id": "joker_greedy", "enabled": true},
		{"id": "joker_flat_bonus", "name": "Flat Bonus Joker", "rule_id": "joker_flat_bonus", "enabled": true},
		{"id": "joker_pair_mult", "name": "Pair Mult Joker", "rule_id": "joker_pair_mult", "enabled": true},
		{"id": "joker_face_chips", "name": "Face Chips Joker", "rule_id": "joker_face_chips", "enabled": true},
		{"id": "joker_flush_xmult", "name": "Flush XMult Joker", "rule_id": "joker_flush_xmult", "enabled": true}
	]
	_load_joker_rules()
	_build_deck()
	_shuffle_deck()
	_draw_to_hand()
	last_result = {"log": ["New run started. Target score: %s" % TARGET_SCORE]}

func toggle_card(card_id: String) -> void:
	if selected_ids.has(card_id):
		selected_ids.erase(card_id)
		return
	if selected_ids.size() >= PLAY_LIMIT:
		return
	selected_ids.append(card_id)

func play_selected() -> Dictionary:
	var selected := _selected_cards()
	if selected.is_empty():
		last_result = {"log": ["Select at least one card."]}
		return last_result
	if hands_left <= 0:
		last_result = {"log": ["No hands left."]}
		return last_result

	hands_left -= 1
	var evaluated := evaluate_hand(selected)
	var chips: int = evaluated["base_chips"]
	var mult: float = evaluated["base_mult"]
	var xmult: float = 1.0
	var log: Array[String] = []
	log.append("Played %s." % evaluated["kind"])
	log.append("Base: %s chips x %s mult." % [chips, mult])

	var on_hand := _execute_jokers("OnHandPlayed", evaluated["scoring_cards"], evaluated["kind"])
	chips += int(on_hand["chips_delta"])
	mult += float(on_hand["mult_delta"])
	xmult *= float(on_hand["xmult_factor"])
	log.append_array(on_hand["log"])

	for card in evaluated["scoring_cards"]:
		var card_chips := _card_chip_value(card)
		chips += card_chips
		log.append("%s adds %s chips." % [_card_label(card), card_chips])

	var on_score := _execute_jokers("OnCardScored", evaluated["scoring_cards"], evaluated["kind"])
	chips += int(on_score["chips_delta"])
	mult += float(on_score["mult_delta"])
	xmult *= float(on_score["xmult_factor"])
	log.append_array(on_score["log"])

	var hand_score := int(round(float(chips) * mult * xmult))
	score += hand_score
	log.append("Result: %s chips x %.1f mult x %.1f = %s." % [chips, mult, xmult, hand_score])
	log.append("Run score: %s / %s." % [score, TARGET_SCORE])
	if score >= TARGET_SCORE:
		log.append("Blind cleared. Prototype round complete.")
	elif hands_left == 0:
		log.append("Out of hands. Run failed.")

	_remove_selected_from_hand()
	selected_ids.clear()
	_draw_to_hand()
	last_result = {
		"hand_kind": evaluated["kind"],
		"chips": chips,
		"mult": mult,
		"xmult": xmult,
		"hand_score": hand_score,
		"log": log
	}
	return last_result

func discard_selected() -> Dictionary:
	var selected := _selected_cards()
	if selected.is_empty():
		last_result = {"log": ["Select cards to discard."]}
		return last_result
	if discards_left <= 0:
		last_result = {"log": ["No discards left."]}
		return last_result

	discards_left -= 1
	var labels := []
	for card in selected:
		labels.append(_card_label(card))
	_remove_selected_from_hand()
	selected_ids.clear()
	_draw_to_hand()
	last_result = {"log": ["Discarded: %s." % ", ".join(labels)]}
	return last_result

func can_continue() -> bool:
	return score < TARGET_SCORE and hands_left > 0

func hand_labels() -> Array[String]:
	var result: Array[String] = []
	for card in hand:
		var marker := "*" if selected_ids.has(card.get("id")) else " "
		result.append("%s %s" % [marker, _card_label(card)])
	return result

func joker_labels() -> Array[String]:
	var result: Array[String] = []
	for joker in jokers:
		result.append("%s [%s]" % [joker.get("name"), "on" if joker.get("enabled") else "off"])
	return result

func evaluate_hand(cards: Array) -> Dictionary:
	var groups := {}
	var suit_counts := {}
	var unique_ranks: Array[int] = []
	for card in cards:
		groups[card.get("rank")] = groups.get(card.get("rank"), [])
		groups[card.get("rank")].append(card)
		suit_counts[card.get("suit")] = suit_counts.get(card.get("suit"), 0) + 1
		if not unique_ranks.has(card.get("rank")):
			unique_ranks.append(card.get("rank"))
	unique_ranks.sort()

	var group_values: Array = groups.values()
	group_values.sort_custom(func(a, b): return a.size() > b.size() if a.size() != b.size() else a[0].get("rank") > b[0].get("rank"))
	var is_flush := suit_counts.values().any(func(count): return count >= 5)
	var is_straight := _is_straight(unique_ranks)

	if is_flush and is_straight:
		return _hand_result("StraightFlush", 100, 8, cards)
	if group_values[0].size() == 4:
		return _hand_result("FourOfAKind", 60, 7, group_values[0])
	if group_values[0].size() == 3 and group_values.size() > 1 and group_values[1].size() >= 2:
		return _hand_result("FullHouse", 40, 4, group_values[0] + group_values[1].slice(0, 2))
	if is_flush:
		return _hand_result("Flush", 35, 4, cards)
	if is_straight:
		return _hand_result("Straight", 30, 4, cards)
	if group_values[0].size() == 3:
		return _hand_result("ThreeOfAKind", 30, 3, group_values[0])
	var pairs := group_values.filter(func(group): return group.size() == 2)
	if pairs.size() >= 2:
		return _hand_result("TwoPair", 20, 2, pairs[0] + pairs[1])
	if group_values[0].size() == 2:
		return _hand_result("Pair", 10, 2, group_values[0])

	var high := cards.duplicate()
	high.sort_custom(func(a, b): return a.get("rank") > b.get("rank"))
	return _hand_result("HighCard", 5, 1, [high[0]])

func _hand_result(kind: String, base_chips: int, base_mult: int, scoring_cards: Array) -> Dictionary:
	return {"kind": kind, "base_chips": base_chips, "base_mult": base_mult, "scoring_cards": scoring_cards}

func _is_straight(ranks: Array[int]) -> bool:
	if ranks.size() < 5:
		return false
	for i in range(0, ranks.size() - 4):
		if ranks[i + 4] - ranks[i] == 4:
			return true
	return ranks.has(14) and ranks.has(2) and ranks.has(3) and ranks.has(4) and ranks.has(5)

func _execute_jokers(trigger: String, scoring_cards: Array, hand_kind: String = "") -> Dictionary:
	var total := {"chips_delta": 0, "mult_delta": 0.0, "xmult_factor": 1.0, "log": []}
	var ctx := {
		"run": {"score": score, "hands_left": hands_left, "discards_left": discards_left},
		"scoring_cards": scoring_cards,
		"jokers": jokers,
		"trigger": trigger,
		"hand_kind": hand_kind
	}
	for joker in jokers:
		if not joker.get("enabled"):
			continue
		var rule = joker_rules.get(joker.get("rule_id"))
		if rule == null or rule.get_trigger() != trigger:
			continue
		var result: Dictionary = rule.execute(ctx)
		total["chips_delta"] += int(result.get("chips_delta", 0))
		total["mult_delta"] += float(result.get("mult_delta", 0.0))
		total["xmult_factor"] *= float(result.get("xmult_factor", 1.0))
		var label := "+%s chips, +%.1f mult, x%.1f" % [result.get("chips_delta", 0), result.get("mult_delta", 0.0), result.get("xmult_factor", 1.0)]
		total["log"].append("%s triggered: %s." % [joker.get("name"), label])
	return total

func _load_joker_rules() -> void:
	joker_rules.clear()
	var paths := [
		"res://content/rules/jokers/joker_greedy.gd",
		"res://content/rules/jokers/joker_flat_bonus.gd",
		"res://content/rules/jokers/joker_pair_mult.gd",
		"res://content/rules/jokers/joker_face_chips.gd",
		"res://content/rules/jokers/joker_flush_xmult.gd"
	]
	for path in paths:
		var script: Script = load(path)
		if script == null:
			continue
		var rule = script.new()
		joker_rules[rule.get_id()] = rule

func _build_deck() -> void:
	deck.clear()
	var index := 0
	for suit in SUITS:
		for rank in RANKS:
			deck.append({"id": "%s_%s_%s" % [suit, rank, index], "suit": suit, "rank": rank})
			index += 1

func _shuffle_deck() -> void:
	for i in range(deck.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var temp = deck[i]
		deck[i] = deck[j]
		deck[j] = temp

func _draw_to_hand() -> void:
	while hand.size() < HAND_LIMIT and not deck.is_empty():
		hand.append(deck.pop_back())

func _selected_cards() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for card in hand:
		if selected_ids.has(card.get("id")):
			result.append(card)
	return result

func _remove_selected_from_hand() -> void:
	var kept: Array[Dictionary] = []
	for card in hand:
		if selected_ids.has(card.get("id")):
			discard_pile.append(card)
		else:
			kept.append(card)
	hand = kept

func _card_chip_value(card: Dictionary) -> int:
	if card.get("rank") == 14:
		return 11
	if card.get("rank") >= 11:
		return 10
	return int(card.get("rank"))

func _card_label(card: Dictionary) -> String:
	return "%s%s" % [_rank_label(card.get("rank")), _suit_symbol(card.get("suit"))]

func _rank_label(rank: int) -> String:
	match rank:
		11: return "J"
		12: return "Q"
		13: return "K"
		14: return "A"
		_: return str(rank)

func _suit_symbol(suit: String) -> String:
	match suit:
		"Spades": return "S"
		"Hearts": return "H"
		"Clubs": return "C"
		"Diamonds": return "D"
		_: return "?"