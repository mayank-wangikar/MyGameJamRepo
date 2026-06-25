extends Node2D

@export var wall_height := 540.0
@export var wall_width := 40.0
const SEGMENTS := 8

var critical := {}
var hits := 0

@onready var g1: AnimatedSprite2D = $g1
@onready var g2: AnimatedSprite2D = $g2
@onready var g3: AnimatedSprite2D = $g3
@onready var g4: AnimatedSprite2D = $g4

var bubble1: Area2D = null
var bubble2: Area2D = null

func _ready() -> void:
	add_to_group("wall")
	_pick_critical()
	queue_redraw()
	_spawn_bubbles()

func _pick_critical() -> void:
	critical.clear()
	var indices := range(SEGMENTS)
	indices.shuffle()
	for i in randi_range(2, 3):
		critical[indices[i]] = true

func _spawn_bubbles() -> void:
	# Position bubble1 between g2 and g1, bubble2 between g3 and g4
	bubble1 = _make_bubble(lerp(g2.position, g1.position, 0.5))
	bubble2 = _make_bubble(lerp(g3.position, g4.position, 0.5))
	add_child(bubble1)
	add_child(bubble2)

func _make_bubble(pos: Vector2) -> Area2D:
	var area := Area2D.new()
	area.position = pos

	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 14.0
	shape.shape = circle
	area.add_child(shape)

	# Connect hit signal
	area.body_entered.connect(func(body):
		if body.is_in_group("projectile"):
			_on_bubble_hit(area)
	)
	return area

func _on_bubble_hit(bubble: Area2D) -> void:
	if bubble == bubble1 and bubble1 != null:
		g1.play("spin")
		g2.play("spin")
		bubble1.queue_free()
		bubble1 = null
	elif bubble == bubble2 and bubble2 != null:
		g3.play("spin")
		g4.play("spin")
		bubble2.queue_free()
		bubble2 = null

func has_critical_remaining() -> bool:
	return true in critical.values()

func hit(global_point: Vector2) -> bool:
	return false  # wall no longer handles hits directly

func _draw() -> void:
	# Draw wall
	var segment_height: float = wall_height / SEGMENTS
	for i in SEGMENTS:
		var seg_top: float = -wall_height / 2.0 + i * segment_height
		var rect := Rect2(-wall_width / 2.0, seg_top, wall_width, segment_height)
		draw_rect(rect, Color(0.6, 0.6, 0.6, 0.6), true)
		draw_rect(rect, Color.WHITE, false, 2.0)

	# Draw bubbles
	if bubble1 != null:
		draw_circle(bubble1.position, 14.0, Color(0.2, 0.9, 0.3, 0.8))
	if bubble2 != null:
		draw_circle(bubble2.position, 14.0, Color(0.2, 0.9, 0.3, 0.8))
