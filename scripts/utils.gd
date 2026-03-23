extends Node

@export var load_scene : PackedScene
@export var in_time : float = 0.5
@export var fade_in_time : float = 1.5
@export var pause_time : float = 1.5
@export var fade_out_time : float = 1.5
@export var out_time : float = 0.5 

func fade(target : Object, scene : PackedScene) -> void:
	
	target.modulate.a = 0.0
	var tween = self.create_tween()
	tween.tween_interval(in_time)
	tween.tween_property(target, "modulate:a", 1.0, fade_in_time)
	tween.tween_interval(pause_time)
	tween.tween_property(target, "modulate:a", 1.0, fade_out_time)
	tween.tween_interval(out_time)
	await tween.finished
	
	get_tree().change_scene_to_packed(scene)
