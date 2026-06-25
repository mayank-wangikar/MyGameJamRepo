extends Node2D

@export var wall_width := 40.0
@export var wall_height := 540.0

@onready var g1: AnimatedSprite2D = $g1
@onready var g2: AnimatedSprite2D = $g2
@onready var g3: AnimatedSprite2D = $g3
@onready var g4: AnimatedSprite2D = $g4

var gear_state := {"g1": false, "g2": false, "g3": false, "g4": false}

# Cooldown so one projectile can't toggle the same gear multiple times
var gear_cooldown := {"g1": 0.0, "g2": 0.0, "g3": 0.0, "g4": 0.0}
const COOLDOWN_TIME := 0.5

func _ready() -> void:
	add_to_group("wall")
	_randomize_states()

func _randomize_states() -> void:
	var all_on := true
	while all_on:
		for key in gear_state:
			gear_state[key] = bool(randi() % 2)
		all_on = gear_state.values().all(func(v): return v)
	_apply_states()

func _apply_states() -> void:
	_set_gear(g1, gear_state["g1"])
	_set_gear(g2, gear_state["g2"])
	_set_gear(g3, gear_state["g3"])
	_set_gear(g4, gear_state["g4"])

func _set_gear(gear: AnimatedSprite2D, on: bool) -> void:
	if on:
		gear.play("gearrun")
	else:
		gear.stop()
		gear.frame = 0

func _process(delta: float) -> void:
	# Tick down cooldowns
	for key in gear_cooldown:
		if gear_cooldown[key] > 0.0:
			gear_cooldown[key] -= delta

	for projectile in get_tree().get_nodes_in_group("projectile"):
		_check_gear(g1, "g1", projectile)
		_check_gear(g2, "g2", projectile)
		_check_gear(g3, "g3", projectile)
		_check_gear(g4, "g4", projectile)

func _check_gear(gear: AnimatedSprite2D, key: String, projectile: Node) -> void:
	if gear_cooldown[key] > 0.0:
		return
	var dist := gear.global_position.distance_to(projectile.global_position)
	if dist < 50.0:
		_lights_out_toggle(key)
		gear_cooldown[key] = COOLDOWN_TIME

func _lights_out_toggle(key: String) -> void:
	match key:
		"g2": _toggle_gear("g2"); _toggle_gear("g1")
		"g1": _toggle_gear("g1"); _toggle_gear("g2"); _toggle_gear("g3")
		"g3": _toggle_gear("g3"); _toggle_gear("g1"); _toggle_gear("g4")
		"g4": _toggle_gear("g4"); _toggle_gear("g3")
	print("Hit ", key, " → states now: ", gear_state)
	_check_win()

func _toggle_gear(key: String) -> void:
	gear_state[key] = not gear_state[key]
	match key:
		"g1": _set_gear(g1, gear_state["g1"])
		"g2": _set_gear(g2, gear_state["g2"])
		"g3": _set_gear(g3, gear_state["g3"])
		"g4": _set_gear(g4, gear_state["g4"])
	print(key, " is now ", "ON" if gear_state[key] else "OFF")
	_check_win()

func _check_win() -> void:
	if gear_state.values().all(func(v): return v):
		print("ALL GEARS ON — Puzzle solved!")
		var game_manager = get_tree().current_scene
		if game_manager.has_method("_check_win_condition"):
			game_manager._check_win_condition()

func hit(_global_point: Vector2) -> bool:
	return false

func has_critical_remaining() -> bool:
	return not gear_state.values().all(func(v): return v)
