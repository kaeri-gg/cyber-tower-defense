class_name ModalManager
extends Control

@onready var settings: Control = %SettingsControl
@onready var close_button: CloseButton = %CloseButton

var modal_views: Dictionary[String, Control] = {}

func _ready() -> void:
	modal_views = {
		"settings": settings,
	}

	sound_manager.play("EnterGame")
	
	close_button.on_click.connect(_close_modal)
	
func open_modal(view_name: String) -> void:
	for view in modal_views.values():
		if view:
			view.hide()
	
	var target_view : Control = modal_views.get(view_name)
	if not target_view:
		push_warning("Modal view '%s' was not found." % view_name)
		return
	
	target_view.show()
	self.show()

func open_settings_modal() -> void:
	open_modal("settings")

func _close_modal() -> void:
	self.hide()
