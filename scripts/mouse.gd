extends Node2D

var _tween: Tween = null
const MOUSE_SIZE := 18.0
var attached_to_wheel: bool = false
var wheel_node: Node2D = null

func _ready() -> void:
	queue_redraw()

func _process(_delta: float) -> void:
	if attached_to_wheel and wheel_node != null:
		# Sit on the rim of the wheel, rotating with it
		var offset := Vector2(wheel_node.radius, 0).rotated(wheel_node.rotation)
		global_position = wheel_node.global_position + offset

func _draw() -> void:
	draw_circle(Vector2.ZERO, MOUSE_SIZE, Color(1.0, 0.45, 0.0))
	draw_circle(Vector2.ZERO, MOUSE_SIZE, Color.WHITE, false, 2.0)
	draw_circle(Vector2(-10, -14), 6.0, Color(1.0, 0.45, 0.0))
	draw_circle(Vector2(10, -14), 6.0, Color(1.0, 0.45, 0.0))
	draw_circle(Vector2(-6, -4), 3.0, Color.BLACK)
	draw_circle(Vector2(6, -4), 3.0, Color.BLACK)

func go_typing() -> void:
	attached_to_wheel = false
	wheel_node = null
	_move_to(Vector2(480, 472))

func go_shooting(wheel: Node2D) -> void:
	attached_to_wheel = true
	wheel_node = wheel
	# No tween needed — _process will track the wheel every frame

func _move_to(target: Vector2) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "position", target, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
