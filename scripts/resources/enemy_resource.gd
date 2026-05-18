class_name EnemyResource
extends Resource

@export var enemy: enemy_types
@export var hp: int = 100
@export var speed: int = 70
@export var armor: int = 0
@export var crypto_resistance: int = 0
@export var lives_cost: int = 1
@export var threat_level: threat_levels
@export var ability: abilities
@export var display_name: String = ""

# speed scale: VerySlow=30, Slow=50, Medium=70, Fast=100, VeryFast=140
# hp scale: Low=100, Medium=200, High=300, Huge=400

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

# Flavor only for now — shown in tooltips, no gameplay effect.
enum abilities {
	STEALTH,
	RESISTANCE,
	PAYLOAD,
	DATA_LEAK,
	CONTAGION,
	SWARM,
	TANK
}