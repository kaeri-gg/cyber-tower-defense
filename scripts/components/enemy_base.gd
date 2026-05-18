class_name Enemy
extends CharacterBody2D

signal died(enemy: Enemy)
signal reached_end(enemy: Enemy)

@export var enemy_stats: EnemyResource

var path_follow: PathFollow2D
var current_hp: int = 0

@onready var label: Label = $Label
@onready var polygon: Polygon2D = $Polygon2D
@onready var hp_bar: ProgressBar = $HPBar

func _ready() -> void:
	if enemy_stats:
		current_hp = enemy_stats.hp
		label.text = enemy_stats.display_name if enemy_stats.display_name != "" else "Enemy"
		hp_bar.max_value = enemy_stats.hp
		hp_bar.value = enemy_stats.hp
		_update_hp_bar_color()
	add_to_group("enemies")

func _update_hp_bar_color() -> void:
	# Lerp the bar fill from green (full HP) through yellow to red (low HP).
	var ratio: float = clamp(float(current_hp) / float(enemy_stats.hp), 0.0, 1.0)
	var c: Color = Color(0.95, 0.3, 0.3).lerp(Color(0.3, 0.95, 0.4), ratio)
	# ProgressBar uses the "fg" stylebox color via theme_override. Set via modulate
	# on the bar itself for a simple effect.
	hp_bar.modulate = c

func setup(new_path_follow: PathFollow2D) -> void:
	path_follow = new_path_follow

func get_enemy_type() -> int:
	return enemy_stats.enemy if enemy_stats else -1

func _process(delta: float) -> void:
	if path_follow == null or enemy_stats == null:
		return
	path_follow.progress += enemy_stats.speed * delta
	if path_follow.progress_ratio >= 1.0:
		reached_end.emit(self)
		_cleanup()

func take_damage(amount: int) -> void:
	if current_hp <= 0:
		return
	current_hp -= max(1, amount)
	hp_bar.value = current_hp
	_update_hp_bar_color()
	polygon.modulate = Color(1, 0.6, 0.6)
	var tw := create_tween()
	tw.tween_property(polygon, "modulate", Color.WHITE, 0.15)
	if current_hp <= 0:
		died.emit(self)
		_cleanup()

func _cleanup() -> void:
	# Free our PathFollow2D parent (which owns us). Defer so any
	# in-flight signal/tween finishes before nodes are freed.
	if path_follow and is_instance_valid(path_follow):
		path_follow.queue_free()
	else:
		queue_free()
