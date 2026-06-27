extends Node2D
@onready var typing_game: Control = $TypingGame
@onready var wheel = $Launch/wheel
@onready var mouse = $Mouse
@onready var right_wall = $Launch/RightWall
@onready var camera: Camera2D = $Camera2D
@onready var bar_label: Label = $CanvasLayer/MarginContainer/VBoxContainer/Label
@onready var bar: ProgressBar = $CanvasLayer/MarginContainer/VBoxContainer/ProgressBar
@onready var roll: Node2D = $Roll

const DRAIN_PER_SECOND: float = 10.0
const PLATFORM_POS := Vector2(480, 490)
const PLATFORM_W := 900.0
const PLATFORM_H := 8.0
const ZOOM_IN := Vector2(3.5, 3.5)
const ZOOM_OUT := Vector2(1.0, 1.0)
const ZOOM_SPEED := 3.0

enum Phase { TYPING, SHOOTING, WON }
var current_phase: Phase = Phase.TYPING
var shooting_energy: float = 0.0
var _display_energy: float = 0.0
var _target_zoom: Vector2 = ZOOM_OUT
var _target_camera_pos: Vector2 = Vector2(480, 270)

func _ready() -> void:
	typing_game.typing_phase_ended.connect(_on_typing_phase_ended)
	typing_game.energy_changed.connect(_on_energy_changed)
	bar.min_value = 0.0
	bar.max_value = 100.0
	# Snap camera instantly to mouse position before first frame
	camera.position = mouse.position
	camera.zoom = ZOOM_IN
	_target_zoom = ZOOM_IN
	_target_camera_pos = mouse.position
	_enter_typing_phase()


func _process(delta: float) -> void:
	camera.zoom = camera.zoom.lerp(_target_zoom, ZOOM_SPEED * delta)
	camera.position = camera.position.lerp(_target_camera_pos, ZOOM_SPEED * delta)
	if current_phase == Phase.SHOOTING:
		shooting_energy = max(0.0, shooting_energy - DRAIN_PER_SECOND * delta)
		_display_energy = shooting_energy
		if shooting_energy <= 0.0:
			_enter_typing_phase()
	_update_bar()
	queue_redraw()

func _update_bar() -> void:
	bar.value = _display_energy
	if current_phase == Phase.TYPING:
		bar_label.text = "Energy: %d / 100" % int(_display_energy)
	else:
		bar_label.text = "Shots: %d s" % int(shooting_energy / 10.0)

func _on_typing_phase_ended(energy_earned: int) -> void:
	if current_phase == Phase.TYPING:
		_enter_shooting_phase(energy_earned)

func _on_energy_changed(value: int) -> void:
	_display_energy = float(value)

func _enter_typing_phase() -> void:
	current_phase = Phase.TYPING
	wheel.is_active = false
	mouse.go_typing()
	typing_game.reset_for_new_typing_phase()
	await get_tree().create_timer(0.5).timeout
	_target_zoom = ZOOM_IN
	_target_camera_pos = mouse.position
	roll.get_node("Roller").play("roller")
	await get_tree().process_frame
	typing_game.visible = true
	typing_game.is_active = true

func _enter_shooting_phase(energy_earned: int) -> void:
	current_phase = Phase.SHOOTING
	typing_game.visible = false
	typing_game.is_active = false
	wheel.is_active = true
	shooting_energy = float(energy_earned)
	_display_energy = shooting_energy
	mouse.go_shooting(wheel)
	_target_zoom = ZOOM_OUT
	_target_camera_pos = Vector2(0, 0)
	roll.get_node("Roller").stop()

func _draw() -> void:
	draw_rect(
		Rect2(PLATFORM_POS - Vector2(PLATFORM_W / 2.0, 0), Vector2(PLATFORM_W, PLATFORM_H)),
		Color(0.7, 0.5, 0.2)
	)

func _check_win_condition() -> void:
	if not right_wall.has_critical_remaining():
		current_phase = Phase.WON
		typing_game.is_active = false
		wheel.is_active = false
		print("YOU WIN!")
