extends Sprite2D

# --- spin ---
var angular_velocity := 0.0
const FRICTION := 1.2
const SPIN_PER_PRESS := 1.5
const MAX_SPIN := 25.0

# --- ring look (tweak these in the Inspector) ---
@export var radius := 120.0
@export var rim_width := 12.0
@export var spokes := 8
var ring_color := Color.WHITE

func _ready() -> void:
	_recenter()
	get_viewport().size_changed.connect(_recenter)

func _recenter() -> void:
	global_position = get_viewport_rect().size / 2.0
	
func _process(delta: float) -> void:
	rotation += angular_velocity * delta
	angular_velocity = move_toward(angular_velocity, 0.0, FRICTION * delta)

func add_spin() -> void:
	angular_velocity = min(angular_velocity + SPIN_PER_PRESS, MAX_SPIN)

func _draw() -> void:
	# the rim — a full-circle arc is the ring
	draw_arc(Vector2.ZERO, radius, 0, TAU, 64, ring_color, rim_width, true)
	# spokes (these are what make the spin actually visible)
	for i in spokes:
		var dir := Vector2(cos(TAU * i / spokes), sin(TAU * i / spokes))
		draw_line(dir * radius * 0.18, dir * (radius - rim_width * 0.5), ring_color, 4.0, true)
	# hub
	draw_circle(Vector2.ZERO, radius * 0.12, ring_color)
