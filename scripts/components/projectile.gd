extends Node2D

var _target: Enemy
var _damage: int
var _speed: float
var _color: Color

func setup(target: Enemy, damage: int, speed: float, color: Color) -> void:
	_target = target
	_damage = damage
	_speed = speed
	_color = color
	queue_redraw()

func _process(delta: float) -> void:
	if not is_instance_valid(_target):
		queue_free()
		return
	var to_target: Vector2 = _target.global_position - global_position
	if to_target.length() <= _speed * delta:
		_target.take_damage(_damage)
		queue_free()
		return
	global_position += to_target.normalized() * _speed * delta

func _draw() -> void:
	draw_circle(Vector2.ZERO, 5.0, _color)
