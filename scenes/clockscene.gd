class_name Dialogue
extends Control

@onready var content: RichTextLabel = $NinePatchRect/content
@onready var type_timer: Timer = $TypeTimer
@onready var confirm_sfx: AudioStreamPlayer = $ConfirmSFX

var is_typing := false

var dialogue_lines := [
	"Hi! I was generated for the dialogue system test.",
	"This is the second line.",
	"And this is the last line."
]

var current_line := 0

func _ready() -> void:
	type_timer.wait_time = 0.02
	await get_tree().create_timer(1.0).timeout
	start_dialogue()

func start_dialogue() -> void:
	current_line = 0
	show()
	update_message(dialogue_lines[current_line])

func update_message(message: String) -> void:
	content.text = message
	content.visible_characters = 0
	is_typing = true
	type_timer.start()

func _on_type_timer_timeout() -> void:
	if content.visible_characters < content.text.length():
		content.visible_characters += 1
	else:
		type_timer.stop()
		is_typing = false

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		confirm_sfx.play()

		if is_typing:
			content.visible_characters = content.text.length()
			type_timer.stop()
			is_typing = false
		else:
			current_line += 1

			if current_line < dialogue_lines.size():
				update_message(dialogue_lines[current_line])
			else:
				end_dialogue()

func end_dialogue() -> void:
	hide()

	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://scenes/ControlsScreen.tscn")
