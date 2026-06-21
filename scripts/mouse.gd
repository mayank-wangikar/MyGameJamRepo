extends Sprite2D

@export var typing_position: Vector2 = Vector2(150, 500)
@export var wheel_position: Vector2 = Vector2(576, 324)
const MOVE_SPEED := 600.0

var target_position: Vector2


func _ready() -> void:
	# Simple placeholder look: a colored square via a generated texture,
	# so there's something visible without needing real art yet.
	var img := Image.create(40, 40, false, Image.FORMAT_RGBA8)
	img.fill(Color(1.0, 0.5, 0.2))
	texture = ImageTexture.create_from_image(img)
	target_position = typing_position
	global_position = typing_position


func _process(delta: float) -> void:
	global_position = global_position.move_toward(target_position, MOVE_SPEED * delta)


func move_to_wheel() -> void:
	target_position = wheel_position


func move_to_typing() -> void:
	target_position = typing_position
