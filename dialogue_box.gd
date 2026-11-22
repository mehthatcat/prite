extends CanvasLayer

signal dialogue_finished

@export var chars_per_second := 30.0
@export var box_height := 160.0
@export var box_margin := 24.0
@export var right_speaker := "Sprite"   # character 1: name on the right
@export var left_speaker := "7Up"       # character 2: name on the left

@onready var panel: Panel = $Panel
@onready var name_label: Label = $Panel/NameLabel
@onready var label: RichTextLabel = $Panel/RichTextLabel

var lines: Array = []
var index := 0
var typing := false
var open := false
var tween: Tween

func _ready() -> void:
	# Anchor the panel to the bottom of the screen, stretched across the width
	panel.anchor_left = 0.0
	panel.anchor_right = 1.0
	panel.anchor_top = 1.0
	panel.anchor_bottom = 1.0
	panel.offset_left = box_margin
	panel.offset_right = -box_margin
	panel.offset_top = -(box_height + box_margin)
	panel.offset_bottom = -box_margin
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.offset_left = 16
	label.offset_top = 12
	label.offset_right = -16
	label.offset_bottom = -12
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.scroll_active = false
		# Dialogue text sits below the name label
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.offset_left = 16
	label.offset_top = 48
	label.offset_right = -16
	label.offset_bottom = -12

	# Name label spans the panel width so it can be aligned left or right
	name_label.anchor_left = 0.0
	name_label.anchor_right = 1.0
	name_label.anchor_top = 0.0
	name_label.anchor_bottom = 0.0
	name_label.offset_left = 16
	name_label.offset_right = -16
	name_label.offset_top = 8

	panel.hide()

func start(new_lines: Array) -> void:
	if new_lines.is_empty():
		return
	lines = new_lines
	index = 0
	open = true
	GameState.dialogue_active = true
	panel.show()
	show_line()

func show_line() -> void:
	var speaker := ""
	var text := ""
	var line = lines[index]

	if line is Dictionary:
		speaker = str(line.get("name", ""))
		text = str(line.get("text", ""))
	else:
		text = str(line)
		# "Name: text" format
		var split := text.find(": ")
		if split > 0 and split <= 20:
			speaker = text.substr(0, split)
			text = text.substr(split + 2)

	name_label.text = speaker
	name_label.visible = speaker != ""

	# Right side for character 1, left side for everyone else
	if speaker == right_speaker:
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	else:
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

	label.text = text
	label.visible_characters = 0
	typing = true

	var total := label.get_total_character_count()
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(label, "visible_characters", total, total / chars_per_second)
	tween.finished.connect(_on_typing_done)

func _on_typing_done() -> void:
	typing = false

func _unhandled_input(event: InputEvent) -> void:
	if not open:
		return
	if event.is_action_pressed("dialogue_skip"):
		get_viewport().set_input_as_handled()
		if typing:
			finish_typing()
		else:
			next_line()

func finish_typing() -> void:
	# Show the whole line immediately
	if tween:
		tween.kill()
	label.visible_characters = -1
	typing = false

func next_line() -> void:
	index += 1
	if index >= lines.size():
		close()
	else:
		show_line()

func close() -> void:
	open = false
	panel.hide()
	GameState.dialogue_active = false
	dialogue_finished.emit()
