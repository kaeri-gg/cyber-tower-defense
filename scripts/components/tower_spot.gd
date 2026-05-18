class_name TowerSpot
extends Area2D

signal clicked(spot: TowerSpot)

@export var is_router: bool = false   # Router spots only accept a Firewall

var occupied: bool = false
var current_tower: Node = null
var _hovered: bool = false

func _ready() -> void:
	input_pickable = true
	connect("input_event", _on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	add_to_group("tower_spots")
	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 24.0
	col.shape = shape
	add_child(col)
	queue_redraw()

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		clicked.emit(self)

func _on_mouse_entered() -> void:
	_hovered = true
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	queue_redraw()

func _on_mouse_exited() -> void:
	_hovered = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	queue_redraw()

func mark_occupied(tower: Node) -> void:
	occupied = true
	current_tower = tower
	queue_redraw()

func clear_tower() -> void:
	if current_tower and is_instance_valid(current_tower):
		current_tower.queue_free()
	current_tower = null
	occupied = false
	queue_redraw()

func _draw() -> void:
	# Always draw a small marker so occupied spots still show as clickable (override).
	var base_fill: Color
	var base_ring: Color
	if is_router:
		base_fill = Color(0.95, 0.55, 0.2, 0.25)
		base_ring = Color(1.0, 0.65, 0.25, 0.95)
	else:
		base_fill = Color(0.2, 0.5, 1.0, 0.3)
		base_ring = Color(0.4, 0.7, 1.0, 0.85)

	if occupied:
		# Tiny diamond marker around the tower so the spot is still findable.
		var c := base_ring
		c.a = 0.6 if _hovered else 0.35
		draw_arc(Vector2.ZERO, 26.0, 0.0, TAU, 24, c, 1.5)
		return

	if _hovered:
		base_fill.a = min(1.0, base_fill.a + 0.2)
		base_ring.a = 1.0
		draw_circle(Vector2.ZERO, 24.0, base_fill)
		draw_arc(Vector2.ZERO, 24.0, 0.0, TAU, 32, base_ring, 3.0)
	else:
		draw_circle(Vector2.ZERO, 22.0, base_fill)
		draw_arc(Vector2.ZERO, 22.0, 0.0, TAU, 32, base_ring, 2.0)