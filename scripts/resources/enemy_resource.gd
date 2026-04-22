class_name EnemyResource
extends Resource

@export var enemy: enemy_types
@export var hp: int = 100
@export var speed: int = 70
@export var armor: int = 0
@export var crypto_resistance: int = 0
@export var bounty: int = 5
@export var lives_cost: int = 1
@export var threat_level: threat_levels
@export var sprite_texture: Texture2D
@export var sprite_hframes: int = 1

# speed slow: 40; medium: 70; fast: 110
# threat level: low: 1, medium: 2, boss: 3

enum enemy_types {
	SNIFFER, 
	DDOS, 
	TROJAN,
	SPYWARE,
	VIRUS, 
	PHISHING, 
	RANSOMWARE
}

enum threat_levels {
	LOW,
	MEDIUM, 
	HIGH
}

func find_appearance() -> void: 
	pass
	
