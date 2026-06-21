extends Node2D

# --- Node references ---
@onready var typing_game: Control = $TypingGame
@onready var wheel = $Launch/wheel
@onready var mouse = $Mouse
@onready var camera: Camera2D = $Camera2D
@onready var left_wall = $Launch/LeftWall
@onready var right_wall = $Launch/RightWall

# --- Config ---
const DRAIN_PER_SECOND: float = 10.0   # 100 energy drains to 0 over ~10 seconds
const TYPING_CAMERA_POS := Vector2(150, 300)
const SHOOTING_CAMERA_POS := Vector2(576, 324)
const CAMERA_MOVE_SPEED := 800.0

enum Phase { TYPING, SHOOTING, WON }
var current_phase: Phase = Phase.TYPING
var shooting_energy: float = 0.0
var camera_target: Vector2


func _ready() -> void:
	typing_game.energy_changed.connect(_on_energy_changed)
	_enter_typing_phase()


func _process(delta: float) -> void:
	# Smoothly move the camera toward whichever phase we're in
	camera.global_position = camera.global_position.move_toward(camera_target, CAMERA_MOVE_SPEED * delta)

	if current_phase == Phase.SHOOTING:
		shooting_energy = max(0.0, shooting_energy - DRAIN_PER_SECOND * delta)
		if shooting_energy <= 0.0:
			_enter_typing_phase()


func _on_energy_changed(value: int) -> void:
	if current_phase == Phase.TYPING and value >= 100:
		_enter_shooting_phase()


func _enter_typing_phase() -> void:
	current_phase = Phase.TYPING
	typing_game.is_active = true
	wheel.is_active = false
	camera_target = TYPING_CAMERA_POS
	mouse.move_to_typing()
	typing_game.reset_for_new_typing_phase()


func _enter_shooting_phase() -> void:
	current_phase = Phase.SHOOTING
	typing_game.is_active = false
	wheel.is_active = true
	shooting_energy = 100.0
	camera_target = SHOOTING_CAMERA_POS
	mouse.move_to_wheel()


func _check_win_condition() -> void:
	var left_done: bool = not left_wall.has_critical_remaining()
	var right_done: bool = not right_wall.has_critical_remaining()
	if left_done and right_done:
		current_phase = Phase.WON
		typing_game.is_active = false
		wheel.is_active = false
		print("YOU WIN — all targets destroyed!")
