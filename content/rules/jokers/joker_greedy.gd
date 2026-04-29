extends RefCounted

func get_id() -> String:
	return "joker_greedy"

func get_trigger() -> String:
	return "OnCardScored"

func execute(ctx: Dictionary) -> Dictionary:
	var bonus := 0
	for card in ctx.get("scoring_cards", []):
		if card.get("suit", "") == "hearts":
			bonus += 4
	return {
		"chips_delta": 0,
		"mult_delta": bonus,
		"xmult_factor": 1.0,
		"events": []
	}
