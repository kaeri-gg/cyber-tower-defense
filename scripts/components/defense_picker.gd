class_name DefensePicker
extends PopupPanel

signal selected(spot: TowerSpot, defense_data: DefenseResource)

const FIREWALL       := preload("uid://be6p2vv1tsji3")
const ANTIVIRUS      := preload("uid://dlka1ec5a0kvv")
const ENCRYPTION     := preload("res://resources/defense/encryption.tres")
const UPDATE         := preload("res://resources/defense/update.tres")
const PASSWORD       := preload("res://resources/defense/password.tres")
const CYBER_BEHAVIOR := preload("res://resources/defense/cyber_behavior.tres")

const ENEMY_NAMES := {
	0: "Sniffer", 1: "DDOS", 2: "Trojan", 3: "Spyware",
	4: "Virus", 5: "Phishing", 6: "Ransomware",
}

@onready var v_box: VBoxContainer = $Margin/VBox/Buttons
@onready var title_label: Label   = $Margin/VBox/Title

var _spot: TowerSpot = null

func _ready() -> void:
	hide()

func open_for(spot: TowerSpot, current_money: int) -> void:
	_spot = spot
	for child in v_box.get_children():
		child.queue_free()
	title_label.text = "Override Tower" if spot.occupied else ("Router (Firewall only)" if spot.is_router else "Choose Defense")
	var defenses: Array[DefenseResource] = [FIREWALL, ANTIVIRUS, ENCRYPTION, UPDATE, PASSWORD, CYBER_BEHAVIOR]
	for def in defenses:
		_add_button(def, current_money, spot.is_router)
	# Position popup near the spot, keeping it on-screen. Use full size so the
	# panel renders properly (passing height=0 makes it collapse to invisible).
	var spot_screen_pos := spot.get_global_transform_with_canvas().origin
	var panel_size := Vector2i(300, 380)
	var pos := Vector2i(spot_screen_pos) + Vector2i(20, -20)
	popup(Rect2i(pos, panel_size))

func _add_button(def: DefenseResource, current_money: int, router_only: bool) -> void:
	var btn := Button.new()
	var defeats_text := _defeats_text(def)
	btn.text = "%s  (%dg)\n   defeats: %s" % [def.display_name, def.base_cost, defeats_text]
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD
	btn.custom_minimum_size = Vector2(260, 50)
	var allowed := (def.tower_name == 0) if router_only else true
	var affordable := current_money >= def.base_cost
	btn.disabled = not allowed or not affordable
	if not allowed:
		btn.tooltip_text = "Router spot — Firewall only"
	elif not affordable:
		btn.tooltip_text = "Not enough money"
	btn.pressed.connect(func() -> void: _on_selected(def))
	v_box.add_child(btn)

func _defeats_text(def: DefenseResource) -> String:
	var names: Array[String] = []
	for t in def.defeats:
		names.append(ENEMY_NAMES.get(t, "?"))
	return ", ".join(names)

func _on_selected(def: DefenseResource) -> void:
	hide()
	if _spot:
		selected.emit(_spot, def)
		_spot = null