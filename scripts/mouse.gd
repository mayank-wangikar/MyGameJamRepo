extends Node2D

var _tween: Tween = null
const MOUSE_SIZE := 18.0
var attached_to_wheel: bool = false
var wheel_node: Node2D = null
var _start_position: Vector2  # ← stores wherever the mouse begins

@onready var _sprite: AnimatedSprite2D = $Mouse

func _ready() -> void:
	_start_position = position  # ← capture starting position on scene load
	queue_redraw()

func _process(_delta: float) -> void:
	if attached_to_wheel and wheel_node != null:
		var offset := Vector2(wheel_node.radius, 0).rotated(wheel_node.rotation)
		global_position = wheel_node.global_position + offset

func go_typing() -> void:
	attached_to_wheel = false
	wheel_node = null
	_sprite.play("crank")
	_move_to(_start_position)  # ← snap back to starting position

func go_shooting(wheel: Node2D) -> void:
	attached_to_wheel = true
	wheel_node = wheel
	_sprite.stop()

func _move_to(target: Vector2) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "position", target, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
