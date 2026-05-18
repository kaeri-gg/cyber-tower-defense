class_name DefenseResource
extends Resource

@export var tower_name: tower_names
@export var display_name: String = ""
@export var description: String = ""
@export var defeats: Array[int] = []   # values from EnemyResource.enemy_types
@export var base_cost: int = 50

@export_group("Combat")
@export var damage: int = 20
@export var range: float = 140.0
@export var fire_rate: float = 1.0       # ticks per second while target in range

@export_group("Visuals")
@export var tower_color: Color = Color(0.4, 0.9, 1.0)
@export var pulse_color: Color = Color(1.0, 1.0, 0.5)

enum tower_names {
	FIREWALL,
	ANTIVIRUS,
	ENCRYPTION,
	UPDATE,
	PASSWORD,
	CYBER_BEHAVIOR
}