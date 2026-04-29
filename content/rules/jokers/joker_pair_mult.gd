extends RefCounted

func get_id() -> String:
	return "joker_pair_mult"

func get_trigger() -> String:
	return "OnHandPlayed"

func execute(ctx: Dictionary) -> Dictionary:
	var hand_kind := str(ctx.get("hand_kind", ""))
	var bonus := 8 if hand_kind == "Pair" else 0
	return {
		"chips_delta": 0,
		"mult_delta": bonus,
		"xmult_factor": 1.0,
		"events": []
	}