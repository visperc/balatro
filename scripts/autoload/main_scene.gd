extends Control

@export var run_script: Script

@onready var stats: Label = $RootMargin/Layout/Stats
@onready var cards_grid: GridContainer = $RootMargin/Layout/MainPanel/LeftPanel/LeftMargin/LeftLayout/CardsGrid
@onready var play_button: Button = $RootMargin/Layout/MainPanel/LeftPanel/LeftMargin/LeftLayout/Actions/PlayButton
@onready var discard_button: Button = $RootMargin/Layout/MainPanel/LeftPanel/LeftMargin/LeftLayout/Actions/DiscardButton
@onready var new_run_button: Button = $RootMargin/Layout/MainPanel/LeftPanel/LeftMargin/LeftLayout/Actions/NewRunButton
@onready var jokers_label: RichTextLabel = $RootMargin/Layout/MainPanel/RightPanel/RightMargin/RightLayout/Jokers
@onready var log_label: RichTextLabel = $RootMargin/Layout/MainPanel/RightPanel/RightMargin/RightLayout/Log

var run
var card_buttons: Dictionary = {}

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	discard_button.pressed.connect(_on_discard_pressed)
	new_run_button.pressed.connect(_on_new_run_pressed)
	_start_new_run()

func _start_new_run() -> void:
	run = run_script.new()
	run.start(Time.get_unix_time_from_system() as int)
	_render_all()

func _render_all() -> void:
	_render_stats()
	_render_hand()
	_render_jokers()
	_render_log(run.last_result.get("log", []))

func _render_stats() -> void:
	stats.text = "Score %s / %s | Hands %s | Discards %s | Deck %s | Selected %s/5" % [
		run.score,
		run.TARGET_SCORE,
		run.hands_left,
		run.discards_left,
		run.deck.size(),
		run.selected_ids.size()
	]
	play_button.disabled = run.selected_ids.is_empty() or run.hands_left <= 0 or run.score >= run.TARGET_SCORE
	discard_button.disabled = run.selected_ids.is_empty() or run.discards_left <= 0 or run.score >= run.TARGET_SCORE

func _render_hand() -> void:
	for child in cards_grid.get_children():
		child.queue_free()
	card_buttons.clear()
	for card in run.hand:
		var button := Button.new()
		button.custom_minimum_size = Vector2(132, 72)
		button.toggle_mode = true
		button.button_pressed = run.selected_ids.has(card.get("id"))
		button.text = _card_button_text(card)
		button.pressed.connect(func(): _on_card_pressed(card.get("id")))
		cards_grid.add_child(button)
		card_buttons[card.get("id")] = button

func _render_jokers() -> void:
	var lines: Array[String] = []
	for label in run.joker_labels():
		lines.append("[b]%s[/b]" % label)
	lines.append("")
	lines.append("Greedy Joker: +4 mult for each scoring heart.")
	lines.append("Flat Bonus Joker: +10 chips when hand is played.")
	lines.append("Pair Mult Joker: +8 mult on Pair.")
	lines.append("Face Chips Joker: +10 chips per scoring J/Q/K.")
	lines.append("Flush XMult Joker: x2 on Flush or Straight Flush.")
	jokers_label.text = "\n".join(lines)

func _render_log(lines: Array) -> void:
	if lines.is_empty():
		log_label.text = "No actions yet."
		return
	var output: Array[String] = []
	for line in lines:
		output.append("- %s" % line)
	log_label.text = "\n".join(output)

func _on_card_pressed(card_id: String) -> void:
	run.toggle_card(card_id)
	_render_stats()
	_render_hand()

func _on_play_pressed() -> void:
	run.play_selected()
	_render_all()

func _on_discard_pressed() -> void:
	run.discard_selected()
	_render_all()

func _on_new_run_pressed() -> void:
	_start_new_run()

func _card_button_text(card: Dictionary) -> String:
	var selected := "SELECTED\n" if run.selected_ids.has(card.get("id")) else ""
	return "%s%s\n%s chips" % [selected, run._card_label(card), run._card_chip_value(card)]