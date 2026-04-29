extends RefCounted

func get_id() -> String:
	return "joker_flush_xmult"

func get_trigger() -> String:
	return "OnHandPlayed"

func execute(ctx: Dictionary) -> Dictionary:
	var hand_kind := str(ctx.get("hand_kind", ""))
	var factor := 2.0 if hand_kind == "Flush" or hand_kind == "StraightFlush" else 1.0
	return {
		"chips_delta": 0,
		"mult_delta": 0,
		"xmult_factor": factor,
		"events": []
	}