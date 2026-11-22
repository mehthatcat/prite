extends Area2D

@export var dialogue_box: Node            # drag your DialogueBox here
@export_multiline var lines: Array[String] = []
@export var one_shot := true              # only play once
@export var trigger_group := "players"    # who can trigger it

var used := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	print("yap: ready. monitoring=", monitoring, " mask=", collision_mask)
	for child in get_children():
		if child is CollisionShape2D:
			print("yap: shape=", child.shape, " disabled=", child.disabled)

func _on_body_entered(body: Node2D) -> void:
	print("yap: body entered -> ", body.name)

	if used and one_shot:
		print("yap: blocked, already used")
		return
	if GameState.dialogue_active:
		print("yap: blocked, dialogue_active is true")
		return
	if not body.is_in_group(trigger_group):
		print("yap: blocked, ", body.name, " is not in group '", trigger_group, "'")
		return
	if dialogue_box == null:
		print("yap: blocked, Dialogue Box slot is empty in the Inspector")
		return
	if lines.is_empty():
		print("yap: blocked, Lines array is empty in the Inspector")
		return

	print("yap: starting dialogue with ", lines.size(), " lines")
	used = true
	dialogue_box.start(lines)
