extends Node2D

# --- Layout ---
@export var wall_height := 400.0      # total height of the wall
@export var wall_width := 30.0        # thickness of the wall
const SEGMENTS := 8                   # number of stacked segments

# --- Critical (green) segments ---
var critical := {}                    # segment index -> still active (true)


func _ready() -> void:
	add_to_group("wall")
	_pick_critical()
	queue_redraw()


func _pick_critical() -> void:
	critical.clear()
	var indices := range(SEGMENTS)
	indices.shuffle()
	# Mark 2-3 random segments as the "perfect hit" green zones
	for i in randi_range(2, 3):
		critical[indices[i]] = true


func hit(global_point: Vector2) -> bool:
	var local_y: float = to_local(global_point).y
	var segment_height: float = wall_height / SEGMENTS
	var seg: int = int((local_y + wall_height / 2.0) / segment_height)
	seg = clamp(seg, 0, SEGMENTS - 1)

	if critical.get(seg, false):
		critical[seg] = false
		queue_redraw()
		return true   # perfect hit!
	return false       # hit the wall, but not a green segment


func _draw() -> void:
	var segment_height: float = wall_height / SEGMENTS
	for i in SEGMENTS:
		var seg_top: float = -wall_height / 2.0 + i * segment_height
		var rect := Rect2(-wall_width / 2.0, seg_top, wall_width, segment_height)
		var color: Color = Color(0.2, 0.9, 0.3, 0.8) if critical.get(i, false) else Color(0.6, 0.6, 0.6, 0.6)
		draw_rect(rect, color, true)
		draw_rect(rect, Color.WHITE, false, 2.0)
		
func has_critical_remaining() -> bool:
	return true in critical.values()
