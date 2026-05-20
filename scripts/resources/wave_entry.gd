class_name WaveEntry
extends Resource

# One group of enemies to spawn during a wave.
# A single wave may contain multiple entries (e.g. 5 Sniffers on left, then 3 Trojans on right).

@export var enemy_stats: EnemyResource
@export var count: int = 1
@export var interval: float = 0.8           # seconds between spawns within this entry
@export var lane: lanes = lanes.LEFT
@export var start_delay: float = 0.0        # delay before this entry begins, after wave start

enum lanes {
	LEFT,
	RIGHT,
	BOTTOM
}
