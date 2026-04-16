class_name Enemy
extends CharacterBody2D

@export var enemy_stats: EnemyResource

var path_follow: PathFollow2D

func setup(new_path_follow: PathFollow2D): 
	path_follow = new_path_follow
	
func _process(delta: float) -> void:
	if path_follow == null or enemy_stats == null:
		return
	path_follow.progress += enemy_stats.speed * delta
