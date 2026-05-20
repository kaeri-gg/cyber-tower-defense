extends Node2D

const ENEMY_SCENE  := preload("uid://pkapuxp7aub1")
const TOWER_SCENE  := preload("uid://c284dlrklulka")

const SNIFFER     := preload("res://resources/enemy/sniffer_stats.tres")
const DDOS        := preload("res://resources/enemy/ddos_stats.tres")
const TROJAN      := preload("res://resources/enemy/trojan_stats.tres")
const SPYWARE     := preload("res://resources/enemy/spyware_stats.tres")
const VIRUS       := preload("res://resources/enemy/virus_stats.tres")
const PHISHING    := preload("res://resources/enemy/phishing_stats.tres")
const RANSOMWARE  := preload("res://resources/enemy/ransomware_stats.tres")

const COOLDOWN_SECONDS: float = 15.0
const TRICKLE_MIN: int = 1
const TRICKLE_MAX: int = 2

# Lane indices match WaveEntry.lanes
enum Lane { LEFT, RIGHT, BOTTOM }

@onready var path_left: Path2D     = %PathLeft
@onready var path_right: Path2D    = %PathRight
@onready var path_bottom: Path2D   = %PathBottom
@onready var towers_node: Node2D   = %Towers
@onready var gold_label: Label     = %GoldLabel
@onready var lives_label: Label    = %LivesLabel
@onready var wave_label: Label     = %WaveLabel
@onready var cooldown_label: Label = %CooldownLabel
@onready var selected_label: Label = %SelectedLabel
@onready var start_btn: Button     = %StartBtn
@onready var defense_picker: PopupPanel = %DefensePicker
@onready var server_core: Node2D        = %ServerCore
@onready var game_over_overlay: Control = %GameOverOverlay
@onready var game_over_label: Label     = %GameOverLabel

# Wave definitions. Each wave is an Array of WaveEntry-like dicts:
#   { stats, count, interval, lane, start_delay }
# Inline as Dictionaries for the demo (Step 7 plan).
var waves: Array = []

var wave_index: int = -1
var enemies_alive: int = 0
var wave_in_progress: bool = false
var cooldown_active: bool = false
var started: bool = false
var _cooldown_remaining: float = 0.0
var _enemy_pool: Array = []

func _ready() -> void:
	_enemy_pool = [SNIFFER, DDOS, TROJAN, SPYWARE, VIRUS, PHISHING]  # HIGH-threat enemies excluded from trickle
	_build_waves()
	game_state.reset()
	game_state.gold_changed.connect(func(v: int) -> void: gold_label.text = "Money: %d" % v)
	game_state.lives_changed.connect(func(v: int) -> void: lives_label.text = "Server HP: %d" % v)
	game_state.wave_changed.connect(func(v: int) -> void: wave_label.text = "Wave: %d / %d" % [v, waves.size()])
	game_state.game_over.connect(_on_game_over)

	for spot in get_tree().get_nodes_in_group("tower_spots"):
		(spot as TowerSpot).clicked.connect(_on_tower_spot_clicked)
	defense_picker.selected.connect(_on_picker_selected)

	cooldown_label.text = ""
	gold_label.text = "Money: %d" % game_state.gold
	lives_label.text = "Server HP: %d" % game_state.lives
	wave_label.text = "Wave: 0 / %d" % waves.size()
	selected_label.text = "Click a tower spot to place a defense. Orange ring = Router (Firewall only)."

func _build_waves() -> void:
	# Wave 1 — recon: Sniffers down the left lane.
	# Wave 2 — phishing pressure on right, Sniffers on left.
	# Wave 3 — DDOS push down the middle, Trojans flanking.
	# Wave 4 — multi-vector (Virus, Spyware, Phishing) across all lanes.
	# Wave 5 — Ransomware boss + escorts.
	waves = [
		[
			{stats = SNIFFER,  count = 5, interval = 0.8, lane = Lane.LEFT,   start_delay = 0.0},
		],
		[
			{stats = SNIFFER,  count = 4, interval = 0.7, lane = Lane.LEFT,   start_delay = 0.0},
			{stats = PHISHING, count = 4, interval = 0.6, lane = Lane.RIGHT,  start_delay = 1.5},
		],
		[
			{stats = DDOS,     count = 3, interval = 1.6, lane = Lane.BOTTOM, start_delay = 0.0},
			{stats = TROJAN,   count = 3, interval = 1.2, lane = Lane.LEFT,   start_delay = 2.0},
			{stats = TROJAN,   count = 3, interval = 1.2, lane = Lane.RIGHT,  start_delay = 2.0},
		],
		[
			{stats = VIRUS,    count = 4, interval = 0.9, lane = Lane.LEFT,   start_delay = 0.0},
			{stats = SPYWARE,  count = 4, interval = 0.9, lane = Lane.RIGHT,  start_delay = 0.0},
			{stats = PHISHING, count = 5, interval = 0.5, lane = Lane.BOTTOM, start_delay = 3.0},
		],
		[
			{stats = RANSOMWARE, count = 2, interval = 4.0, lane = Lane.BOTTOM, start_delay = 0.0},
			{stats = DDOS,       count = 3, interval = 1.5, lane = Lane.LEFT,   start_delay = 1.0},
			{stats = TROJAN,     count = 4, interval = 1.0, lane = Lane.RIGHT,  start_delay = 1.0},
		],
	]

func _on_start_pressed() -> void:
	if started or game_state.is_game_over:
		return
	started = true
	start_btn.hide()
	_start_next_wave()

func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/world/level_01.tscn")

func _on_game_over(won: bool) -> void:
	game_over_overlay.show()
	var wave_reached: int = clamp(wave_index + 1, 1, waves.size())
	if won:
		game_over_label.text = "VICTORY!\nAll %d waves cleared." % waves.size()
	else:
		game_over_label.text = "GAME OVER\nReached wave %d / %d" % [wave_reached, waves.size()]

func _on_tower_spot_clicked(spot: TowerSpot) -> void:
	if game_state.is_game_over:
		return
	defense_picker.open_for(spot, game_state.gold)

func _on_picker_selected(spot: TowerSpot, def: DefenseResource) -> void:
	if not game_state.spend_gold(def.base_cost):
		selected_label.text = "Not enough money for %s." % def.display_name
		return
	if spot.occupied:
		var refund := 0
		if spot.current_tower != null and is_instance_valid(spot.current_tower) and spot.current_tower.tower_data != null:
			refund = spot.current_tower.tower_data.base_cost / 2
		spot.clear_tower()
		if refund > 0:
			game_state.add_gold(refund)
	var tower: DefenseTower = TOWER_SCENE.instantiate()
	tower.tower_data = def
	tower.global_position = spot.global_position
	towers_node.add_child(tower)
	spot.mark_occupied(tower)
	selected_label.text = "Placed %s (-%dg)." % [def.display_name, def.base_cost]

# ---------------------------------------------------------------- wave loop

func _start_next_wave() -> void:
	wave_index += 1
	if wave_index >= waves.size():
		return
	game_state.set_wave(wave_index + 1)
	cooldown_label.text = ""
	wave_in_progress = true
	_spawn_wave(waves[wave_index])

func _spawn_wave(wave: Array) -> void:
	# Each entry runs in parallel as its own coroutine. Box the counter so
	# the lambda can mutate it (GDScript lambdas can read but not reassign
	# outer locals — a reference type sidesteps that).
	var pending := [wave.size()]
	for entry in wave:
		_run_entry(entry, func() -> void:
			pending[0] -= 1
			if pending[0] == 0:
				wave_in_progress = false
				_check_wave_end()
		)

func _run_entry(entry: Dictionary, on_done: Callable) -> void:
	if entry.start_delay > 0.0:
		await get_tree().create_timer(entry.start_delay).timeout
	for i in entry.count:
		_spawn_enemy(entry.stats, entry.lane)
		if i < entry.count - 1:
			await get_tree().create_timer(entry.interval).timeout
	on_done.call()

func _spawn_enemy(stats: EnemyResource, lane: int) -> void:
	var path := _path_for_lane(lane)
	var path_follow := PathFollow2D.new()
	path_follow.loop = false
	path_follow.rotates = false
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	enemy.enemy_stats = stats
	enemy.setup(path_follow)
	path_follow.add_child(enemy)
	path.add_child(path_follow)
	enemies_alive += 1
	enemy.reached_end.connect(_on_enemy_reached_end)
	enemy.tree_exited.connect(_on_enemy_removed)

func _path_for_lane(lane: int) -> Path2D:
	match lane:
		Lane.RIGHT:  return path_right
		Lane.BOTTOM: return path_bottom
		_:           return path_left

func _on_enemy_reached_end(_enemy: Enemy) -> void:
	game_state.lose_life(1)
	_flash_server()

func _flash_server() -> void:
	var poly := server_core.get_node_or_null("Polygon2D") as Polygon2D
	if poly == null:
		return
	poly.modulate = Color(1.4, 0.5, 0.5)
	var tw := create_tween()
	tw.tween_property(poly, "modulate", Color.WHITE, 0.35)

func _on_enemy_removed() -> void:
	enemies_alive -= 1
	_check_wave_end()

func _check_wave_end() -> void:
	if wave_in_progress or enemies_alive > 0 or game_state.is_game_over or cooldown_active:
		return
	if wave_index + 1 >= waves.size():
		game_state.win()
	else:
		game_state.add_gold(50)
		_run_cooldown()

# -------------------------------------------------------- cooldown + trickle

func _run_cooldown() -> void:
	cooldown_active = true
	_cooldown_remaining = COOLDOWN_SECONDS
	var trickle_count := randi_range(TRICKLE_MIN, TRICKLE_MAX)
	for i in trickle_count:
		var when := randf_range(1.0, COOLDOWN_SECONDS - 1.0)
		_spawn_trickle_at(when)
	while _cooldown_remaining > 0.0 and not game_state.is_game_over:
		cooldown_label.text = "Next wave in %0.1fs" % _cooldown_remaining
		await get_tree().create_timer(0.1).timeout
		_cooldown_remaining -= 0.1
	cooldown_label.text = ""
	cooldown_active = false
	if game_state.is_game_over:
		return
	_start_next_wave()

func _spawn_trickle_at(delay: float) -> void:
	# Detached coroutine: waits then spawns one random-type enemy on a random lane.
	await get_tree().create_timer(delay).timeout
	if game_state.is_game_over:
		return
	var stats: EnemyResource = _enemy_pool.pick_random()
	var lane := randi() % 3
	_spawn_enemy(stats, lane)
