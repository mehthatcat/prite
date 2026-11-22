extends Area2D

@export var teleport_offset := Vector2(0, -20)   # lands slightly above the other player

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("players"):
		return

	var player := body as CharacterBody2D
	if player == null:
		return

	# Find the other player
	var other: Node2D = null
	for p in get_tree().get_nodes_in_group("players"):
		if p != player:
			other = p
			break

	if other != null:
		player.velocity = Vector2.ZERO
		player.global_position = other.global_position + teleport_offset
	elif player.has_method("die"):
		# No other player yet (player 2 still deactivated): go back to start
		player.die()
