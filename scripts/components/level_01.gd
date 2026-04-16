extends Node2D

var enemy_scene = preload("uid://pkapuxp7aub1")
@onready var path_2d: Path2D = %Path2D

func _ready() -> void:
	var path_follow = PathFollow2D.new()
	var enemy = enemy_scene.instantiate()
	enemy.setup(path_follow)
	path_follow.add_child(enemy)
	path_2d.add_child(path_follow)

func _process(delta: float) -> void:
	pass
