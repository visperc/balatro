extends Control

@onready var status: Label = $RootMargin/Layout/Panel/PanelMargin/PanelLayout/Status
@onready var start_button: Button = $RootMargin/Layout/ButtonRow/StartButton
@onready var quit_button: Button = $RootMargin/Layout/ButtonRow/QuitButton

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	status.text = "Runtime ready · content version: %s" % Game.content_version

func _on_start_pressed() -> void:
	status.text = "Sample requested · next step is binding this button to C# rule simulation"
	print("Sample requested from UI")

func _on_quit_pressed() -> void:
	get_tree().quit()