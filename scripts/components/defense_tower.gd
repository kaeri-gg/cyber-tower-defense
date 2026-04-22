class_name DefenseTower
extends Node2D

@export var tower_data: DefenseResource

var _cooldown: float = 0.0
var _sprite: Sprite2D
var _range_indicator: Node2D

func _ready() -> void:
	_sprite = Sprite2D.new()
	if tower_data and tower_data.sprite_texture:
		_sprite.texture = tower_data.sprite_texture
	add_child(_sprite)
	add_to_group("towers")

func _process(delta: float) -> void:
	if tower_data == null:
		return
	_cooldown = max(0.0, _cooldown - delta)
	if _cooldown > 0.0:
		return
	var target := _find_target()
	if target:
		_shoot(target)
		_cooldown = 1.0 / tower_data.fire_rate

func _find_target() -> Enemy:
	var best: Enemy = null
	var best_progress: float = -1.0
	for e in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(e):
			continue
		var enemy := e as Enemy
		var dist := global_position.distance_to(enemy.global_position)
		if dist > tower_data.range:
			continue
		# prefer enemy furthest along the path
		if enemy.path_follow and enemy.path_follow.progress > best_progress:
			best_progress = enemy.path_follow.progress
			best = enemy
	return best

func _shoot(target: Enemy) -> void:
	var proj := preload("res://scenes/components/projectile.tscn").instantiate()
	proj.setup(target, tower_data.damage, tower_data.projectile_speed, tower_data.projectile_color)
	proj.global_position = global_position
	get_tree().current_scene.add_child(proj)
