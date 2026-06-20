extends Control

signal correct_press
	
# --- Node references ---
@onready var timer: Timer = $Timer
@onready var target_label: Label = $MarginContainer/VBoxContainer/TargetLabel
@onready var progress_label: Label = $MarginContainer/VBoxContainer/ProgressLabel
@onready var accuracy_label: Label = $MarginContainer/VBoxContainer/AccuracyLabel
@onready var time_label: Label = $MarginContainer/VBoxContainer/TimeLabel
@onready var high_score_label: Label = $MarginContainer/VBoxContainer/HighScoreLabel

# --- Config ---
const ALLOWED_KEYS: Array[String] = ["A", "S", "D", "F", "J", "K", "L", ";"]
const TARGET_LENGTH: int = 4
const ROUND_DURATION: float = 30.0

const KEY_TO_STRING: Dictionary = {
	KEY_A: "A", KEY_S: "S", KEY_D: "D", KEY_F: "F",
	KEY_J: "J", KEY_K: "K", KEY_L: "L", KEY_SEMICOLON: ";",
}

# --- State ---
var target_set: Array[String] = []
var current_index: int = 0
var round_correct_presses: int = 0
var round_total_presses: int = 0
var high_score_accuracy: float = 0.0
var time_remaining: float = ROUND_DURATION


func _ready() -> void:
	randomize()
	timer.wait_time = ROUND_DURATION
	timer.one_shot = false
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	_start_new_round()


func _process(delta: float) -> void:
	time_remaining = max(0.0, time_remaining - delta)
	time_label.text = "Time: %d s" % ceil(time_remaining)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key_event := event as InputEventKey
		var pressed_string: String = KEY_TO_STRING.get(key_event.keycode, "")
		if pressed_string == "":
			return
		_handle_key_press(pressed_string)
		get_viewport().set_input_as_handled()


func _handle_key_press(pressed_key: String) -> void:
	if current_index >= target_set.size():
		return
	var expected_key: String = target_set[current_index]
	round_total_presses += 1
	if pressed_key == expected_key:
		round_correct_presses += 1
		current_index += 1
		correct_press.emit()
	_update_accuracy_display()
	_update_progress_display()
	if current_index >= target_set.size():
		# Word stays the same until the 30s timer fires.
		# Loop back to the start so the player can retype it again.
		current_index = 0
		_update_progress_display()


func _on_timer_timeout() -> void:
	var final_accuracy: float = _calculate_accuracy()
	if final_accuracy > high_score_accuracy:
		high_score_accuracy = final_accuracy
		high_score_label.text = "High Score: %d%%" % round(high_score_accuracy)
	_start_new_round()


func _start_new_round() -> void:
	round_correct_presses = 0
	round_total_presses = 0
	time_remaining = ROUND_DURATION
	_generate_new_target()
	_update_accuracy_display()
	_update_progress_display()


func _generate_new_target() -> void:
	target_set.clear()
	current_index = 0
	for i in range(TARGET_LENGTH):
		target_set.append(ALLOWED_KEYS[randi() % ALLOWED_KEYS.size()])
	target_label.text = " ".join(target_set)


func _update_progress_display() -> void:
	var parts: Array[String] = []
	for i in range(target_set.size()):
		parts.append(target_set[i] if i < current_index else "_")
	progress_label.text = " ".join(parts)


func _update_accuracy_display() -> void:
	accuracy_label.text = "Accuracy: %d%%" % round(_calculate_accuracy())


func _calculate_accuracy() -> float:
	if round_total_presses == 0:
		return 100.0
	return (float(round_correct_presses) / float(round_total_presses)) * 100.0
