extends Node2D

@export var player1: Node2D
@export var player2: CharacterBody2D
@export var activate_x := -1200   # when player 1 passes this x, player 2 wakes up

var triggered := false

func _process(_delta: float) -> void:
	if triggered:
		return
	if player1.global_position.x >= activate_x:
		triggered = true
		player2.activate()
@onready var dialogue_box = $dialoguebox

func _ready() -> void:
	dialogue_box.start([
		"???: Where...am I?",
		"???: It's really cold...",
		"???: Wait...",
		"???: Who am I?",
		"???: Let me see...",
		"???: What does that can say?",
		"???: ...Prite?",
		"Prite: My name is Prite?"
	])
