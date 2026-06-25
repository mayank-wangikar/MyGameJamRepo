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

# Energy bar dimensions
const BAR_POS := Vector2(20, 510)
const BAR_W := 200.0
const BAR_H := 16.0

enum Phase { TYPING, SHOOTING, WON }
var current_phase: Phase = Phase.TYPING
var shooting_energy: float = 0.0
var _display_energy: float = 0.0  # tracks what to show on bar

func _ready() -> void:
	typing_game.typing_phase_ended.connect(_on_typing_phase_ended)
	typing_game.energy_changed.connect(_on_energy_changed)
	_enter_typing_phase()

func _process(delta: float) -> void:
	if current_phase == Phase.SHOOTING:
		shooting_energy = max(0.0, shooting_energy - DRAIN_PER_SECOND * delta)
		_display_energy = shooting_energy
		if shooting_energy <= 0.0:
			_enter_typing_phase()
	queue_redraw()

func _on_typing_phase_ended(energy_earned: int) -> void:
	if current_phase == Phase.TYPING:
		_enter_shooting_phase(energy_earned)

func _on_energy_changed(value: int) -> void:
	_display_energy = float(value)

func _enter_typing_phase() -> void:
	current_phase = Phase.TYPING
	typing_game.visible = true
	typing_game.is_active = true
	wheel.is_active = false
	mouse.go_typing()
	typing_game.reset_for_new_typing_phase()

func _enter_shooting_phase(energy_earned: int) -> void:
	current_phase = Phase.SHOOTING
	typing_game.visible = false
	typing_game.is_active = false
	wheel.is_active = true
	shooting_energy = float(energy_earned)
	_display_energy = shooting_energy
	mouse.go_shooting(wheel)

func _draw() -> void:
	# Platform
	draw_rect(
		Rect2(PLATFORM_POS - Vector2(PLATFORM_W / 2.0, 0), Vector2(PLATFORM_W, PLATFORM_H)),
		Color(0.7, 0.5, 0.2)
	)
	# Energy bar background
	draw_rect(Rect2(BAR_POS, Vector2(BAR_W, BAR_H)), Color(0.2, 0.2, 0.2))
	# Energy bar fill
	var fill := (_display_energy / 100.0) * BAR_W
	var bar_color := Color(0.2, 0.9, 0.3) if current_phase == Phase.TYPING else Color(0.9, 0.6, 0.1)
	draw_rect(Rect2(BAR_POS, Vector2(fill, BAR_H)), bar_color)
	# Energy bar border
	draw_rect(Rect2(BAR_POS, Vector2(BAR_W, BAR_H)), Color.WHITE, false, 1.5)
	# Label
	var label := "Energy: %d / 100" % int(_display_energy) if current_phase == Phase.TYPING else "Shots: %d s" % int(shooting_energy / 10.0)
	draw_string(ThemeDB.fallback_font, BAR_POS + Vector2(0, -6), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)

func _check_win_condition() -> void:
	if not left_wall.has_critical_remaining() and not right_wall.has_critical_remaining():
		current_phase = Phase.WON
		typing_game.is_active = false
		wheel.is_active = false
		print("YOU WIN!")
