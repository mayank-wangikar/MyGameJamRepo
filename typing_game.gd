extends Control

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
const ENERGY_PER_CYCLE: int = 10   # energy awarded per fully-completed diamond

# Each entry is a 4-letter cluster matched to real keyboard finger positions.
# Order within each cluster = [Top, Left, Right, Bottom] for the visual diamond.
const DIAMOND_CLUSTERS: Array[Array] = [
	["E", "S", "D", "X"],
	["R", "D", "F", "C"],
	["T", "F", "G", "V"],
	["Y", "G", "H", "B"],
	["U", "H", "J", "N"],
	["I", "J", "K", "M"],
]

# --- State ---
var target_letters: Array[String] = []   # [Top, Left, Right, Bottom] for current round
var current_index: int = 0               # 0=Top, 1=Left, 2=Right, 3=Bottom, 4=done
var time_remaining: float = ROUND_DURATION

# --- Scoring ---
var energy_points: int = 0
var high_score_energy: int = 0


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
if pressed_char == expected_char:
		current_index += 1

	_update_diamond_highlight()

	if current_index >= target_letters.size():
		# Completed all 4 corners — award energy, then roll a new diamond.
		_award_energy_for_cycle()
		_generate_new_target()
	
	_update_energy_display()


func _award_energy_for_cycle() -> void:
	energy_points = int(min(100, energy_points + ENERGY_PER_CYCLE))

func _on_timer_timeout() -> void:
	if energy_points > high_score_energy:
		high_score_energy = energy_points
		high_score_label.text = "High Score: %d Energy" % high_score_energy
	_start_new_round()


func _start_new_round() -> void:
	current_index = 0
	energy_points = 0
	time_remaining = ROUND_DURATION
	_generate_new_target()
	_update_energy_display()


func _generate_new_target() -> void:
	var chosen_cluster: Array = DIAMOND_CLUSTERS[randi() % DIAMOND_CLUSTERS.size()]
	
	# chosen_cluster is stored as [Top, Left, Right, Bottom] (visual order),
	# but target_letters is reordered to [Top, Left, Bottom, Right] —
	# the order the PLAYER must type them in.
	target_letters = [chosen_cluster[0], chosen_cluster[1], chosen_cluster[3], chosen_cluster[2]]
	current_index = 0

	top_label.text = chosen_cluster[0]
	left_label.text = chosen_cluster[1]
	right_label.text = chosen_cluster[2]
	bottom_label.text = chosen_cluster[3]

	_update_diamond_highlight()


func _update_diamond_highlight() -> void:
	# Highlight order follows the TYPING order: Top, Left, Bottom, Right.
	var labels_in_typing_order: Array[Label] = [top_label, left_label, bottom_label, right_label]
	for i in range(labels_in_typing_order.size()):
		if i < current_index:
			labels_in_typing_order[i].modulate = Color(0.4, 0.4, 0.4)   # already typed
		elif i == current_index:
			labels_in_typing_order[i].modulate = Color(1.0, 0.85, 0.2)  # type this one next
		else:
			labels_in_typing_order[i].modulate = Color(1.0, 1.0, 1.0)   # not yet reached


func _update_energy_display() -> void:
	energy_label.text = "Energy: %d / 100" % energy_points
