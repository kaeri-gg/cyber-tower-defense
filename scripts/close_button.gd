class_name CloseButton
extends Control

signal on_click

func close_self() -> void:
	sound_manager.play("Click")
	on_click.emit()
