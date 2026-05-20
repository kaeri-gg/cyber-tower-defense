class_name DefensePicker
extends PopupPanel

signal selected(spot: TowerSpot, defense_data: DefenseResource)

const FIREWALL       := preload("uid://be6p2vv1tsji3")
const ANTIVIRUS      := preload("uid://dlka1ec5a0kvv")
const ENCRYPTION     := preload("res://resources/defense/encryption.tres")
const UPDATE         := preload("res://resources/defense/update.tres")
const PASSWORD       := preload("res://resources/defense/password.tres")
const CYBER_BEHAVIOR := preload("res://resources/defense/cyber_behavior.tres")

@onready var _buttons_box: VBoxContainer = %Buttons
@onready var title_label: Label          = %Title

var _spot: TowerSpot = null

# Keys must match the node name of each Button you place inside %Buttons.
var _defense_by_name: Dictionary

func _ready() -> void:
	_defense_by_name = {
		"Firewall":      FIREWALL,
		"Antivirus":     ANTIVIRUS,
		"Encryption":    ENCRYPTION,
		"Update":        UPDATE,
		"Password":      PASSWORD,
		"CyberBehavior": CYBER_BEHAVIOR,
	}
	for btn in _buttons_box.get_children():
		if btn is Button:
			btn.pressed.connect(_on_button_pressed.bind(btn))
	hide()

func open_for(spot: TowerSpot, current_money: int) -> void:
	_spot = spot
	title_label.text = "Override Tower" if spot.occupied else ("Router (Firewall only)" if spot.is_router else "Install a Defense")
	for btn in _buttons_box.get_children():
		if not btn is Button:
			continue
		var def: DefenseResource = _defense_by_name.get(btn.name)
		if def == null:
			continue
		var allowed := (def.tower_name == 0) if spot.is_router else true
		var affordable := current_money >= def.base_cost
		btn.disabled = not allowed or not affordable
		if not allowed:
			btn.tooltip_text = "Router spot — Firewall only"
		elif not affordable:
			btn.tooltip_text = "Not enough money"
		else:
			btn.tooltip_text = ""
	var spot_screen_pos := spot.get_global_transform_with_canvas().origin
	var panel_size := Vector2i(300, 380)
	var pos := Vector2i(spot_screen_pos) + Vector2i(20, -20)
	popup(Rect2i(pos, panel_size))

func _on_button_pressed(btn: Button) -> void:
	var def: DefenseResource = _defense_by_name.get(btn.name)
	if def and _spot:
		hide()
		selected.emit(_spot, def)
		_spot = null
