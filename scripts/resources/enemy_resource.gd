class_name EnemyResource
extends Resource

@export var enemy: enemy_types
@export var hp: int
@export var speed: int
@export var armor: int
@export var crypto_resistance: int
@export var bounty: int
@export var lives_cost: int
@export var threat_level: threat_levels

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
	
