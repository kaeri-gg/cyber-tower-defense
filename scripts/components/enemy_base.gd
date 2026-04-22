class_name Enemy
extends CharacterBody2D

signal died(bounty: int)
signal reached_end(lives_cost: int)

@export var enemy_stats: EnemyResource

var path_follow: PathFollow2D
var current_hp: int = 0

func _ready() -> void:
	if enemy_stats:
		current_hp = enemy_stats.hp
		var sprite := get_node_or_null("Sprite2D") as Sprite2D
		if sprite and enemy_stats.sprite_texture:
			sprite.texture = enemy_stats.sprite_texture
			sprite.hframes = enemy_stats.sprite_hframes
	add_to_group("enemies")

func setup(new_path_follow: PathFollow2D) -> void:
	path_follow = new_path_follow

func _process(delta: float) -> void:
	if path_follow == null or enemy_stats == null:
		return
	path_follow.progress += enemy_stats.speed * delta
	if path_follow.progress_ratio >= 1.0:
		reached_end.emit(enemy_stats.lives_cost)
		game_state.lose_life(enemy_stats.lives_cost)
		_cleanup()

func take_damage(amount: int) -> void:
	var effective : int = max(1, amount - enemy_stats.armor)
	current_hp -= effective
	modulate = Color(1, 0.5, 0.5)
	create_tween().tween_property(self, "modulate", Color.WHITE, 0.15)
	if current_hp <= 0:
		died.emit(enemy_stats.bounty)
		game_state.add_gold(enemy_stats.bounty)
		sound_manager.play("correct_answer")
		_cleanup()

func _cleanup() -> void:
	if path_follow:
		path_follow.queue_free()
	else:
		queue_free()
