class_name DefenseResource
extends Resource

@export var tower_name: tower_names
@export var tower_type: tower_types
@export var damage_type: damage_types
@export var base_cost: int
@export var target_type: target_types

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
