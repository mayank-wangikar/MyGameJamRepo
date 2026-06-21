extends Node2D

var velocity := Vector2.ZERO
var power := 1.0
const SPEED := 900.0

func launch(direction: Vector2, charge: float) -> void:
	velocity = direction.normalized() * SPEED
	power = charge

func _process(delta: float) -> void:
	position += velocity * delta
	rotation += 20.0 * delta
	var ferris := get_tree().get_first_node_in_group("ferris")
	if ferris and global_position.distance_to(ferris.global_position) < ferris.radius:
		ferris.hit(global_position)
		queue_free()
	elif not get_viewport_rect().grow(400).has_point(global_position):
		queue_free()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 8.0, Color.YELLOW)
