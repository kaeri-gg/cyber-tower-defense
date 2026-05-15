extends Node2D

const ENEMY_SCENE := preload("uid://pkapuxp7aub1")
const SNIFFER    := preload("res://resources/enemy/sniffer_stats.tres")
const TROJAN     := preload("res://resources/enemy/trojan_stats.tres")
const TOWER_SCENE := preload("uid://c284dlrklulka")
const FIREWALL   := preload("uid://be6p2vv1tsji3")
const ANTIVIRUS  := preload("uid://dlka1ec5a0kvv")

@onready var path_2d: Path2D       = %Path2D
@onready var towers_node: Node2D   = %Towers
@onready var gold_label: Label     = %GoldLabel
@onready var lives_label: Label    = %LivesLabel
@onready var wave_label: Label     = %WaveLabel
@onready var selected_label: Label = %SelectedLabel
@onready var game_over_overlay: Control = %GameOverOverlay
@onready var game_over_label: Label     = %GameOverLabel

var _selected_tower_data: DefenseResource = null

var waves: Array = [
	[[SNIFFER, 0.8], [SNIFFER, 0.8], [SNIFFER, 0.8], [SNIFFER, 0.8], [SNIFFER, 0.8]],
	[[SNIFFER, 0.6], [SNIFFER, 0.6], [TROJAN,  1.5], [SNIFFER, 0.6], [SNIFFER, 0.6]],
	[[TROJAN,  1.2], [TROJAN,  1.2], [SNIFFER, 0.5], [SNIFFER, 0.5], [SNIFFER, 0.5]],
	[[SNIFFER, 0.4], [SNIFFER, 0.4], [SNIFFER, 0.4], [TROJAN,  1.0], [TROJAN,  1.0]],
	[[TROJAN,  0.8], [TROJAN,  0.8], [TROJAN,  0.8], [SNIFFER, 0.3], [SNIFFER, 0.3], [SNIFFER, 0.3]],
]

var wave_index: int = -1
var enemies_alive: int = 0
var wave_in_progress: bool = false

func _ready() -> void:
	game_state.reset()
	game_state.gold_changed.connect(func(v: int) -> void: gold_label.text = "Gold: %d" % v)
	game_state.lives_changed.connect(func(v: int) -> void: lives_label.text = "Lives: %d" % v)
	game_state.wave_changed.connect(func(v: int) -> void: wave_label.text = "Wave: %d / %d" % [v, waves.size()])
	game_state.game_over.connect(_on_game_over)
	for spot in get_tree().get_nodes_in_group("tower_spots"):
		(spot as TowerSpot).clicked.connect(_on_tower_spot_clicked)
	_update_hud()
	await get_tree().create_timer(1.0).timeout
	_start_next_wave()

func _update_hud() -> void:
	gold_label.text  = "Gold: %d" % game_state.gold
	lives_label.text = "Lives: %d" % game_state.lives
	wave_label.text  = "Wave: 0 / %d" % waves.size()
	selected_label.text = "No tower selected — pick one below"

func _on_game_over(won: bool) -> void:
	game_over_overlay.show()
	game_over_label.text = "YOU WIN!" if won else "GAME OVER"

func select_firewall() -> void:
	_selected_tower_data = FIREWALL
	selected_label.text = "Selected: Firewall  |  Cost: 50g  |  Click a spot to place"

func select_antivirus() -> void:
	_selected_tower_data = ANTIVIRUS
	selected_label.text = "Selected: Antivirus  |  Cost: 70g  |  Click a spot to place"

func _on_tower_spot_clicked(spot: TowerSpot) -> void:
	if _selected_tower_data == null:
		return
	if not game_state.spend_gold(_selected_tower_data.base_cost):
		selected_label.text = "Not enough gold!"
		return
	var tower: DefenseTower = TOWER_SCENE.instantiate()
	tower.tower_data = _selected_tower_data
	tower.global_position = spot.global_position
	towers_node.add_child(tower)
	spot.mark_occupied()

func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/world/level_01.tscn")

func _start_next_wave() -> void:
	wave_index += 1
	if wave_index >= waves.size():
		return
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
