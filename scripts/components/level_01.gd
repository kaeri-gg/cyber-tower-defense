extends Node2D

const ENEMY_SCENE := preload("uid://pkapuxp7aub1")  # enemy_base.tscn
const SNIFFER := preload("res://resources/enemy/sniffer_stats.tres")
const TROJAN  := preload("res://resources/enemy/trojan_stats.tres")

@onready var path_2d: Path2D = %Path2D

# Each wave: array of [EnemyResource, spawn_delay_seconds]
var waves: Array = [
	[[SNIFFER, 0.8], [SNIFFER, 0.8], [SNIFFER, 0.8], [SNIFFER, 0.8], [SNIFFER, 0.8]],
	[[SNIFFER, 0.6], [SNIFFER, 0.6], [TROJAN, 1.5], [SNIFFER, 0.6], [SNIFFER, 0.6]],
	[[TROJAN, 1.2], [TROJAN, 1.2], [SNIFFER, 0.5], [SNIFFER, 0.5], [SNIFFER, 0.5]],
	[[SNIFFER, 0.4], [SNIFFER, 0.4], [SNIFFER, 0.4], [TROJAN, 1.0], [TROJAN, 1.0]],
	[[TROJAN, 0.8], [TROJAN, 0.8], [TROJAN, 0.8], [SNIFFER, 0.3], [SNIFFER, 0.3], [SNIFFER, 0.3]],
]

var wave_index: int = -1
var enemies_alive: int = 0
var wave_in_progress: bool = false

func _ready() -> void:
	game_state.reset()
	await get_tree().create_timer(1.0).timeout
	_start_next_wave()

func _start_next_wave() -> void:
	wave_index += 1
	if wave_index >= waves.size():
		return  # win handled when last enemy dies
	game_state.set_wave(wave_index + 1)
	wave_in_progress = true
	_spawn_wave(waves[wave_index])

func _spawn_wave(wave: Array) -> void:
	for entry in wave:
		var stats: EnemyResource = entry[0]
		var delay: float = entry[1]
		_spawn_enemy(stats)
		await get_tree().create_timer(delay).timeout
	wave_in_progress = false
	_check_wave_end()

func _spawn_enemy(stats: EnemyResource) -> void:
	var path_follow := PathFollow2D.new()
	path_follow.loop = false
	path_follow.rotates = false
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	enemy.enemy_stats = stats
	enemy.setup(path_follow)
	path_follow.add_child(enemy)
	path_2d.add_child(path_follow)
	enemies_alive += 1
	enemy.tree_exited.connect(_on_enemy_removed)

func _on_enemy_removed() -> void:
	enemies_alive -= 1
	_check_wave_end()

func _check_wave_end() -> void:
	if wave_in_progress or enemies_alive > 0 or game_state.is_game_over:
		return
	if wave_index + 1 >= waves.size():
		game_state.win()
	else:
		await get_tree().create_timer(3.0).timeout
		_start_next_wave()
