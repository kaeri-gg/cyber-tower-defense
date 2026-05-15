class_name TowerSpot
extends Area2D

signal clicked(spot: TowerSpot)

var occupied: bool = false

func _ready() -> void:
	input_pickable = true
	connect("input_event", _on_input_event)
	add_to_group("tower_spots")
	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 24.0
	col.shape = shape
	add_child(col)
	queue_redraw()

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not occupied:
			clicked.emit(self)

func mark_occupied() -> void:
	occupied = true
	queue_redraw()

func _draw() -> void:
	if occupied:
		return
	draw_circle(Vector2.ZERO, 22.0, Color(0.2, 0.5, 1.0, 0.3))
	draw_arc(Vector2.ZERO, 22.0, 0.0, TAU, 32, Color(0.4, 0.7, 1.0, 0.85), 2.0)
