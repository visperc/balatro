extends SceneTree

func _init() -> void:
	var run_script: Script = load("res://scripts/gameplay/balatro_run.gd")
	var run = run_script.new()
	run.start(12345)
	if run.hand.size() != run.HAND_LIMIT:
		push_error("Expected initial hand size %s, got %s" % [run.HAND_LIMIT, run.hand.size()])
		quit(1)
		return
	for i in range(0, min(5, run.hand.size())):
		run.toggle_card(run.hand[i].get("id"))
	var result = run.play_selected()
	if int(result.get("hand_score", 0)) <= 0:
		push_error("Expected positive hand score, got %s" % result)
		quit(1)
		return
	print("Smoke OK: %s" % result)
	quit(0)