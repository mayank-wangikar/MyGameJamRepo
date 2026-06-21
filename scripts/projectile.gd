extends Node2D

var velocity := Vector2.ZERO
var power := 1.0
const SPEED := 900.0

var previous_position: Vector2


func launch(direction: Vector2, charge: float) -> void:
	velocity = direction.normalized() * SPEED
	power = charge
	previous_position = global_position
	print("Launch velocity: ", velocity)


func _process(delta: float) -> void:
	previous_position = global_position
	position += velocity * delta
	rotation += 20.0 * delta

	for wall in get_tree().get_nodes_in_group("wall"):
		if _crossed_wall(wall):
			var was_perfect: bool = wall.hit(global_position)
			if was_perfect:
				print("PERFECT HIT!")
				var game_manager = get_tree().current_scene
				if game_manager.has_method("_check_win_condition"):
					game_manager._check_win_condition()
			else:
				print("Hit the wall, but missed the green zone.")
			queue_free()
			return

	if not get_viewport_rect().grow(400).has_point(global_position):
		print("Despawned off-screen at: ", global_position)
		queue_free()

	if not get_viewport_rect().grow(400).has_point(global_position):
		queue_free()


func _crossed_wall(wall: Node2D) -> bool:
	var local_prev: Vector2 = wall.to_local(previous_position)
	var local_now: Vector2 = wall.to_local(global_position)
	var half_width: float = wall.wall_width / 2.0
	var half_height: float = wall.wall_height / 2.0

	var crossed_x: bool = sign(local_prev.x - half_width) != sign(local_now.x - half_width) \
		or sign(local_prev.x + half_width) != sign(local_now.x + half_width) \
		or (abs(local_now.x) <= half_width)

	var within_y: bool = abs(local_now.y) <= half_height
	return crossed_x and within_y


func _draw() -> void:
	draw_circle(Vector2.ZERO, 14.0, Color.YELLOW)
	draw_circle(Vector2.ZERO, 14.0, Color.ORANGE, false, 3.0)
