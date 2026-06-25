extends Control
@onready var main_buttons: VBoxContainer = $MainButtons
@onready var pause_screen: Panel = $PauseScreen

func _ready() -> void:
	main_buttons.visible = true
	pause_screen.visible = false

func _on_options_pressed() -> void:
	main_buttons.visible = false
	options.visible = true

func _on_button_pressed() -> void:
	pass # Replace with function body.
