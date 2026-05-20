extends Node

signal gold_changed(new_value: int)
signal lives_changed(new_value: int)
signal wave_changed(new_value: int)
signal game_over(won: bool)

var gold: int = 0
var lives: int = 0
var current_wave: int = 0
var is_game_over: bool = false

func reset() -> void:
	gold = 500
	lives = 20
	current_wave = 0
	is_game_over = false
	gold_changed.emit(gold)
	lives_changed.emit(lives)
	wave_changed.emit(current_wave)

func add_gold(amount: int) -> void:
	gold += amount
	gold_changed.emit(gold)

func spend_gold(amount: int) -> bool:
	if gold < amount:
		return false
	gold -= amount
	gold_changed.emit(gold)
	return true

func lose_life(amount: int) -> void:
	if is_game_over:
		return
	lives = max(0, lives - amount)
	lives_changed.emit(lives)
	if lives == 0:
		is_game_over = true
		game_over.emit(false)

func set_wave(n: int) -> void:
	current_wave = n
	wave_changed.emit(current_wave)

func win() -> void:
	if is_game_over:
		return
	is_game_over = true
	game_over.emit(true)
