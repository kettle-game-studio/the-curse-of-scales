extends InteractiveArea
class_name Cannon

@export var cannonball: PathFollow3D
@export var move_per_second: float = 2.0;

func shoot(player: Player) -> void:
	await fly(player)
	
func fly(player: Player):
	var state = player.state
	player.state = Player.ScaleState.NONE
	var ratio = 0.0
	while true:
		await get_tree().physics_frame
		ratio += move_per_second / 60.0
		if ratio >= 1.0:
			break
		cannonball.progress_ratio = ratio;
		player.global_position = cannonball.global_position
	cannonball.progress_ratio = 0.0
	player.state = state
