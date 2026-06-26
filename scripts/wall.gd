extends Node2D

@export var wall_width := 40.0
@export var wall_height := 540.0

@onready var g1: AnimatedSprite2D = $g1
@onready var g2: AnimatedSprite2D = $g2
@onready var g3: AnimatedSprite2D = $g3
@onready var g4: AnimatedSprite2D = $g4
@onready var g5: AnimatedSprite2D = $g5
@onready var g6: AnimatedSprite2D = $g6
@onready var g7: AnimatedSprite2D = $g7
@onready var g8: AnimatedSprite2D = $g8
@onready var g9: AnimatedSprite2D = $g9

var gear_state := {
	"g1": false, "g2": false, "g3": false,
	"g4": false, "g5": false, "g6": false,
	"g7": false, "g8": false, "g9": false
}
var gear_cooldown := {
	"g1": 0.0, "g2": 0.0, "g3": 0.0,
	"g4": 0.0, "g5": 0.0, "g6": 0.0,
	"g7": 0.0, "g8": 0.0, "g9": 0.0
}
const COOLDOWN_TIME := 0.5

func _ready() -> void:
	add_to_group("wall")

func _process(delta: float) -> void:
	for key in gear_cooldown:
		if gear_cooldown[key] > 0.0:
			gear_cooldown[key] -= delta
	var gears = {
		"g1": g1, "g2": g2, "g3": g3,
		"g4": g4, "g5": g5, "g6": g6,
		"g7": g7, "g8": g8, "g9": g9
	}
	for projectile in get_tree().get_nodes_in_group("projectile"):
		for key in gears:
			_check_gear(gears[key], key, projectile)

func _check_gear(gear: AnimatedSprite2D, key: String, projectile: Node) -> void:
	if gear_cooldown[key] > 0.0:
		return
	var dist := gear.global_position.distance_to(projectile.global_position)
	if dist < 50.0:
		_toggle_gear(key)
		gear_cooldown[key] = COOLDOWN_TIME

func _toggle_gear(key: String) -> void:
	gear_state[key] = not gear_state[key]
	var gears = {
		"g1": g1, "g2": g2, "g3": g3,
		"g4": g4, "g5": g5, "g6": g6,
		"g7": g7, "g8": g8, "g9": g9
	}
	_set_gear(gears[key], gear_state[key])
	_check_win()

func _set_gear(gear: AnimatedSprite2D, on: bool) -> void:
	if on:
		gear.play("gearrun")
	else:
		gear.stop()
		gear.frame = 0

func _check_win() -> void:
	if gear_state.values().all(func(v): return v):
		print("ALL GEARS ON — Level complete!")
		var game_manager = get_tree().current_scene
		if game_manager.has_method("_check_win_condition"):
			game_manager._check_win_condition()

func has_critical_remaining() -> bool:
	return not gear_state.values().all(func(v): return v)

func hit(_global_point: Vector2) -> bool:
	return false
