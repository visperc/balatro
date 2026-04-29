extends RefCounted

func get_id() -> String:
	return "joker_flat_bonus"

func get_trigger() -> String:
	return "OnHandPlayed"

func execute(ctx: Dictionary) -> Dictionary:
	return {
		"chips_delta": 10,
		"mult_delta": 0,
		"xmult_factor": 1.0,
		"events": []
	}
