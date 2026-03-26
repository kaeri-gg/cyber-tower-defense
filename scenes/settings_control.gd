class_name	Settings
extends Control

@onready var music_volume_slider: HSlider = %MusicVolumeSlider
@onready var sfx_volume_slider: HSlider = %SFXVolumeSlider

func _ready() -> void:
	music_volume_slider.value_changed.connect(_set_bus_volume.bind("Music"))
	sfx_volume_slider.value_changed.connect(_set_bus_volume.bind("SFX"))
	
	music_volume_slider.drag_ended.connect(_on_slider_drag_ended)
	sfx_volume_slider.drag_ended.connect(_on_slider_drag_ended)

func _on_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		sound_manager.play("Click")
	
func _set_bus_volume(volume: float, bus_name: String) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		push_warning("Audio bus '%s' not found." % bus_name)
		return

	if volume <= 0.0:
		AudioServer.set_bus_volume_db(bus_index, -80.0) 
	else:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(volume / 100.0))
