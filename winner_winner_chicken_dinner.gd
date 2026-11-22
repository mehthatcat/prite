extends Area2D

signal game_won

@export var win_screen: CanvasLayer
@export var players_required := 2        # how many players must be inside

var inside: Array[Node2D] = []
var won := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if win_screen:
		win_screen.hide()

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("players"):
		return
	if not inside.has(body):
		inside.append(body)
	_check_win()

func _on_body_exited(body: Node2D) -> void:
	inside.erase(body)

func _check_win() -> void:
	if won or inside.size() < players_required:
		return

	won = true
	GameState.dialogue_active = true   # reuses the freeze check, so both players stop
	game_won.emit()

	if win_screen:
		win_screen.show()

func _unhandled_input(event: InputEvent) -> void:
	# Optional: press Enter or Space on the win screen to restart
	if won and event.is_action_pressed("ui_accept"):
		GameState.dialogue_active = false
		GameState.last_moved = null
		get_tree().reload_current_scene()
