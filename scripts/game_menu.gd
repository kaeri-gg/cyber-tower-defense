class_name GameMenu
extends Control

const LEVEL_01 = preload("uid://bbosdl4p301n0")

func _ready() -> void:
	sound_manager.play("EnterGame")

func start_game() -> void:
	sound_manager.play("EnterGame")
	get_tree().change_scene_to_packed(LEVEL_01)

func show_about_us() -> void:
	ui_manager.open_about_us_modal()
	sound_manager.play("Click")
