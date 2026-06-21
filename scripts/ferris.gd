extends Node2D

const SEGMENTS := 12
@export var radius := 180.0
@export var spin_speed := 1.2          # radians/sec — set to 0 to test it static

var critical := {}                      # segment index -> still active (true)

func _ready() -> void:
	add_to_group("ferris")
	_pick_critical()
	_place()
	get_viewport().size_changed.connect(_place)
	queue_redraw()

func _place() -> void:
	var vp := get_viewport_rect().size
	global_position = Vector2(vp.x * 0.72, vp.y * 0.5)

func _process(delta: float) -> void:
	rotation += spin_speed * delta

func _pick_critical() -> void:
	critical.clear()
	var indices := range(SEGMENTS)
	indices.shuffle()
	for i in randi_range(2, 3):
		critical[indices[i]] = true

func hit(global_point: Vector2) -> bool:
	var local_angle := fposmod((global_point - global_position).angle() - rotation, TAU)
	var seg := int(local_angle / (TAU / SEGMENTS))
	if critical.get(seg, false):
		critical[seg] = false
		queue_redraw()
		if not true in critical.values():
			spin_speed = 0.0
			print("Ferris wheel stopped — you win!")
		return true
	return false

func _draw() -> void:
	var step := TAU / SEGMENTS
	for i in SEGMENTS:
		if critical.get(i, false):
			var pts := PackedVector2Array([Vector2.ZERO])
			for s in 9:
				pts.append(Vector2.from_angle(i * step + step * s / 8.0) * radius)
			draw_colored_polygon(pts, Color(1, 0.3, 0.2, 0.5))
		draw_line(Vector2.ZERO, Vector2.from_angle(i * step) * radius, Color.WHITE, 2.0, true)
	draw_arc(Vector2.ZERO, radius, 0, TAU, 64, Color.WHITE, 6.0, true)
