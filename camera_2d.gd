extends Camera2D

@export var follow_speed := 5.0

func _process(delta: float) -> void:
	var players := get_tree().get_nodes_in_group("players")
	if players.is_empty():
		return

	var target := Vector2.ZERO
	for p in players:
		target += p.global_position
	target /= players.size()

	global_position = global_position.lerp(target, follow_speed * delta)
