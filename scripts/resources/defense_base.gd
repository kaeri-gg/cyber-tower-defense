class_name DefenseResource
extends Resource

@export var tower_name: tower_names
@export var tower_type: tower_types
@export var damage_type: damage_types
@export var target_type: target_types
@export var base_cost: int = 70

@export_group("Combat")
@export var damage: int = 20
@export var range: float = 180.0
@export var fire_rate: float = 1.0       # shots per second
@export var projectile_speed: float = 400.0

@export_group("Visuals")
@export var sprite_texture: Texture2D
@export var projectile_color: Color = Color(0.4, 0.9, 1.0)

enum tower_names {
	FIREWALL,
	ANTIVIRUS, 
	ENCRYPTION,
	UPDATE, 
	PASSWORD,
	CYBER_BEHAVIOR
}

enum tower_types {
	BLOCKER,
	RANGED_DPS,
	RANGED_AOE,
	SLOW_UTILITY,
	SUPPORT_BUFF
}

enum damage_types {
	SCAN,
	CRYPTO,
	PATCH
}

enum target_types {
	MELEE, 
	SINGLE, 
	AREA, 
	AURA
}
