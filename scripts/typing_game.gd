extends Control

signal diamond_completed          # fired every time a full diamond cycle finishes
signal energy_changed(value: int) # fired whenever energy changes, so GameManager can react

# --- Node references ---
@onready var timer: Timer = $Timer
@onready var top_label: Label = $MarginContainer/VBoxContainer/DiamondContainer/TopLabel
@onready var left_label: Label = $MarginContainer/VBoxContainer/DiamondContainer/LeftLabel
@onready var right_label: Label = $MarginContainer/VBoxContainer/DiamondContainer/RightLabel
@onready var bottom_label: Label = $MarginContainer/VBoxContainer/DiamondContainer/BottomLabel
@onready var energy_label: Label = $MarginContainer/VBoxContainer/AccuracyLabel
@onready var time_label: Label = $MarginContainer/VBoxContainer/TimeLabel
@onready var high_score_label: Label = $MarginContainer/VBoxContainer/HighScoreLabel

# --- Config ---
const ROUND_DURATION: float = 15.0
const ENERGY_PER_CYCLE: int = 10

const DIAMOND_CLUSTERS: Array[Array] = [
	["E", "S", "D", "X"],
	["R", "D", "F", "C"],
	["T", "F", "G", "V"],
	["Y", "G", "H", "B"],
	["U", "H", "J", "N"],
	["I", "J", "K", "M"],
]

# --- State ---
var target_letters: Array[String] = []
var current_index: int = 0
var time_remaining: float = ROUND_DURATION
var energy_points: int = 0
var high_score_energy: int = 0
var is_active: bool = false   # GameManager turns this on/off based on phase


func _ready() -> void:
	randomize()
	timer.wait_time = ROUND_DURATION
	timer.one_shot = false
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	_generate_new_target()
	_update_energy_display()


func _process(delta: float) -> void:
	if not is_active:
		return
	time_remaining = max(0.0, time_remaining - delta)
	time_label.text = "Time: %d s" % ceil(time_remaining)


func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var key_event := event as InputEventKey
		var pressed_char: String = key_event.as_text_key_label().to_upper()
		if pressed_char.length() != 1:
			return
		_handle_key_press(pressed_char)
		get_viewport().set_input_as_handled()


func _handle_key_press(pressed_char: String) -> void:
	if current_index >= target_letters.size():
		return

	var expected_char: String = target_letters[current_index]

	if pressed_char == expected_char:
		current_index += 1

	_update_diamond_highlight()

	if current_index >= target_letters.size():
		_award_energy_for_cycle()
		diamond_completed.emit()
		_generate_new_target()


func _award_energy_for_cycle() -> void:
	energy_points = int(min(100, energy_points + ENERGY_PER_CYCLE))
	_update_energy_display()


func _on_timer_timeout() -> void:
	# Round timer now only refreshes which diamond is shown, NOT energy —
	# energy persists until GameManager resets it (entering a fresh TYPING phase).
	if energy_points > high_score_energy:
		high_score_energy = energy_points
		high_score_label.text = "High Score: %d Energy" % high_score_energy
	time_remaining = ROUND_DURATION
	_generate_new_target()


func reset_for_new_typing_phase() -> void:
	# Called by GameManager when re-entering TYPING after a SHOOTING phase.
	energy_points = 0
	current_index = 0
	time_remaining = ROUND_DURATION
	_generate_new_target()
	_update_energy_display()


func _generate_new_target() -> void:
	var chosen_cluster: Array = DIAMOND_CLUSTERS[randi() % DIAMOND_CLUSTERS.size()]
	target_letters = [chosen_cluster[0], chosen_cluster[1], chosen_cluster[3], chosen_cluster[2]]
	current_index = 0
	top_label.text = chosen_cluster[0]
	left_label.text = chosen_cluster[1]
	right_label.text = chosen_cluster[2]
	bottom_label.text = chosen_cluster[3]
	_update_diamond_highlight()


func _update_diamond_highlight() -> void:
	var labels_in_typing_order: Array[Label] = [top_label, left_label, bottom_label, right_label]
	for i in range(labels_in_typing_order.size()):
		if i < current_index:
			labels_in_typing_order[i].modulate = Color(0.4, 0.4, 0.4)
		elif i == current_index:
			labels_in_typing_order[i].modulate = Color(1.0, 0.85, 0.2)
		else:
			labels_in_typing_order[i].modulate = Color(1.0, 1.0, 1.0)


func _update_energy_display() -> void:
	energy_label.text = "Energy: %d / 100" % energy_points
	energy_changed.emit(energy_points)
