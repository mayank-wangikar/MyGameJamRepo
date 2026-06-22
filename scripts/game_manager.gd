extends Node2D

@onready var typing_game: Control = $TypingGame
@onready var wheel = $Launch/wheel
@onready var mouse = $Mouse
@onready var left_wall = $Launch/LeftWall
@onready var right_wall = $Launch/RightWall

const DRAIN_PER_SECOND: float = 10.0
const PLATFORM_POS := Vector2(480, 490)
const PLATFORM_W := 900.0
const PLATFORM_H := 8.0

enum Phase { TYPING, SHOOTING, WON }
var current_phase: Phase = Phase.TYPING
var shooting_energy: float = 0.0

func _ready() -> void:
	typing_game.energy_changed.connect(_on_energy_changed)
	_enter_typing_phase()

func _process(delta: float) -> void:
	if current_phase == Phase.SHOOTING:
		shooting_energy = max(0.0, shooting_energy - DRAIN_PER_SECOND * delta)
		if shooting_energy <= 0.0:
			_enter_typing_phase()

func _on_energy_changed(value: int) -> void:
	if current_phase == Phase.TYPING and value >= 100:
		_enter_shooting_phase()

func _enter_typing_phase() -> void:
	current_phase = Phase.TYPING
	typing_game.visible = true
	typing_game.is_active = true
	wheel.is_active = false
	mouse.go_typing()
	typing_game.reset_for_new_typing_phase()

func _enter_shooting_phase() -> void:
	current_phase = Phase.SHOOTING
	typing_game.visible = false
	typing_game.is_active = false
	wheel.is_active = true
	shooting_energy = float(typing_game.energy_points)
	mouse.go_shooting(wheel)

func _draw() -> void:
	draw_rect(
		Rect2(PLATFORM_POS - Vector2(PLATFORM_W / 2.0, 0), Vector2(PLATFORM_W, PLATFORM_H)),
		Color(0.7, 0.5, 0.2)
	)

func _check_win_condition() -> void:
	if not left_wall.has_critical_remaining() and not right_wall.has_critical_remaining():
		current_phase = Phase.WON
		typing_game.is_active = false
		wheel.is_active = false
		print("YOU WIN!")
