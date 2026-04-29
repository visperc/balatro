extends RefCounted

func get_id() -> String:
	return "joker_face_chips"

func get_trigger() -> String:
	return "OnCardScored"

func execute(ctx: Dictionary) -> Dictionary:
	var chips := 0
	for card in ctx.get("scoring_cards", []):
		var rank := int(card.get("rank", 0))
		if rank >= 11 and rank <= 13:
			chips += 10
	return {
		"chips_delta": chips,
		"mult_delta": 0,
		"xmult_factor": 1.0,
		"events": []
	}