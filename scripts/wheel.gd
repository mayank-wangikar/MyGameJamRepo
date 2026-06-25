extends Node2D

@export var projectile_scene: PackedScene
@export var radius := 60.0
@export var rim_width := 8.0
@export var spokes := 8
const SPIN_SPEED := 5.0
const LAUNCH_POWER := 1.0
var ring_color := Color.WHITE
var is_active: bool = false

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D  # adjust name if needed

func _ready() -> void:
	_sprite.stop()

func _process(delta: float) -> void:
	if not is_active:
		return
	rotation += SPIN_SPEED * delta

func set_active(value: bool) -> void:
	is_active = value
	if is_active:
		_sprite.play("spin")  # replace "spin" with your animation name
	else:
		_sprite.stop()

func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
		_fire()

func _fire() -> void:
	if projectile_scene == null:
		return
	var edge := global_position + Vector2.from_angle(rotation) * radius
	var dir := Vector2.from_angle(rotation + PI / 2.0)
	var p := projectile_scene.instantiate()
	get_tree().current_scene.add_child(p)
	p.global_position = edge
	p.launch(dir, LAUNCH_POWER)
