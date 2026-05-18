class_name DefenseTower
extends Node2D

@export var tower_data: DefenseResource

@onready var visual: Node2D = $Visual
@onready var polygon: Polygon2D = $Visual/Polygon2D
@onready var label: Label = $Visual/Label
@onready var range_area: Area2D = $RangeArea
@onready var range_shape: CollisionShape2D = $RangeArea/CollisionShape2D
@onready var tick_timer: Timer = $TickTimer

var _base_color: Color = Color.WHITE
var _pulse_color: Color = Color.WHITE

func _ready() -> void:
	add_to_group("towers")
	if tower_data == null:
		return
	_base_color = tower_data.tower_color
	_pulse_color = tower_data.pulse_color
	polygon.color = _base_color
	label.text = _short_label()
	(range_shape.shape as CircleShape2D).radius = tower_data.range
	tick_timer.wait_time = 1.0 / max(0.01, tower_data.fire_rate)
	tick_timer.timeout.connect(_on_tick)
	tick_timer.start()
	queue_redraw()

func _draw() -> void:
	if tower_data == null:
		return
	var fill := tower_data.tower_color
	fill.a = 0.08
	draw_circle(Vector2.ZERO, tower_data.range, fill)
	var ring := tower_data.tower_color
	ring.a = 0.28
	draw_arc(Vector2.ZERO, tower_data.range, 0.0, TAU, 48, ring, 1.5)

func _short_label() -> String:
	if tower_data.display_name == "":
		return "Tower"
	# First letter of each word, max 3 chars (e.g. "Cyber Behavior" -> "CB")
	var parts := tower_data.display_name.split(" ", false)
	if parts.size() == 1:
		return parts[0].substr(0, 4)
	var s := ""
	for p in parts:
		s += p.substr(0, 1)
	return s.to_upper()

func _on_tick() -> void:
	var target := _find_target()
	if target == null:
		return
	target.take_damage(tower_data.damage)
	_spawn_tracer(target.global_position)
	_pulse()

func _spawn_tracer(target_pos: Vector2) -> void:
	# Small dot that flies from tower to where the target was at fire time.
	# Purely cosmetic — damage already applied in _on_tick.
	var dot := Polygon2D.new()
	dot.color = _pulse_color
	dot.polygon = PackedVector2Array([Vector2(-4, -4), Vector2(4, -4), Vector2(4, 4), Vector2(-4, 4)])
	dot.global_position = global_position
	get_tree().current_scene.add_child(dot)
	var tw := dot.create_tween()
	tw.set_parallel(true)
	tw.tween_property(dot, "global_position", target_pos, 0.14)
	tw.tween_property(dot, "modulate:a", 0.0, 0.14).set_delay(0.06)
	tw.chain().tween_callback(dot.queue_free)

func _find_target() -> Enemy:
	# Pick the nearest enemy in range whose type is in `defeats`.
	var best: Enemy = null
	var best_dist := INF
	for body in range_area.get_overlapping_bodies():
		if not (body is Enemy):
			continue
		var enemy := body as Enemy
		if not is_instance_valid(enemy) or enemy.current_hp <= 0:
			continue
		if not tower_data.defeats.has(enemy.get_enemy_type()):
			continue
		var d := global_position.distance_squared_to(enemy.global_position)
		if d < best_dist:
			best_dist = d
			best = enemy
	return best

func _pulse() -> void:
	# Snappy up, soft return — feels more like a "kick" than a wobble.
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(visual, "scale", Vector2(1.25, 1.25), 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(polygon, "color", _pulse_color, 0.05)
	tw.chain().set_parallel(true)
	tw.tween_property(visual, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(polygon, "color", _base_color, 0.18)
