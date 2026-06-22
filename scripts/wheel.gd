extends Node2D

@export var projectile_scene: PackedScene
@export var radius := 60.0
@export var rim_width := 8.0
@export var spokes := 8
const SPIN_SPEED := 5.0
const LAUNCH_POWER := 1.0

var ring_color := Color.WHITE
var is_active: bool = false   # GameManager turns this on during SHOOTING phase


#func _ready() -> void:
	#_place()
	#get_viewport().size_changed.connect(_place)


#func _place() -> void:
	#var vp := get_viewport_rect().size
	#global_position = Vector2(vp.x * 0.5, vp.y * 0.5)


func _process(delta: float) -> void:
	if not is_active:
		return
	rotation += SPIN_SPEED * delta


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


func _draw() -> void:
	draw_arc(Vector2.ZERO, radius, 0, TAU, 64, ring_color, rim_width, true)
	for i in spokes:
		var dir := Vector2.from_angle(TAU * i / spokes)
		draw_line(dir * radius * 0.18, dir * (radius - rim_width * 0.5), ring_color, 4.0, true)
	draw_circle(Vector2.ZERO, radius * 0.12, ring_color)
	var launch_pt := Vector2(radius, 0)
	draw_circle(launch_pt, 10.0, Color.YELLOW)
	draw_line(launch_pt, launch_pt + Vector2(0, 1) * 45.0, Color.YELLOW, 3.0, true)
