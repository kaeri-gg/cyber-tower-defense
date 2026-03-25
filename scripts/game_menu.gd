class_name GameMenu
extends Control

@onready var settings_button: SettingsButton = %SettingsButton
@onready var modal_manager: ModalManager = %ModalManager

func _ready() -> void:
	sound_manager.play("EnterGame")
	
	settings_button.on_click.connect(_show_settings)

func start_game() -> void:
	sound_manager.play("EnterGame")

func show_about_us() -> void:
	sound_manager.play("Click")

func _show_settings() -> void:
	modal_manager.open_settings_modal()
