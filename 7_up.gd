extends CharacterBody2D

const SPEED = 400.0
const JUMP_VELOCITY = -1200.0
const HOLD_FRAME := 10           # the jump2 frame to hold during the fall
const FALL_HOLD_SPEED := 800.0   # fall speed at which it moves on from the hold frame
var current_speed = SPEED

var active := false
var transforming := false
var spawn_position: Vector2

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	spawn_position = global_position
	animated_sprite.play("dead")

func activate() -> void:
	if active or transforming:
		return
	transforming = true
	animated_sprite.play("spawn")
	await animated_sprite.animation_finished
	transforming = false
	active = true
	add_to_group("players")

func die() -> void:
	# Ignore spikes while deactivated or transforming
	if not active:
		return
	velocity = Vector2.ZERO
	global_position = spawn_position

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Deactivated or mid-transformation: no input, no animation changes
	if not active:
		velocity.x = 0
		move_and_slide()
		return

	# Freeze during dialogue
	if GameState.dialogue_active:
		velocity.x = 0
		move_and_slide()
		animated_sprite.play("idle2")
		return

	# Jump
	if Input.is_action_just_pressed("jump2") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Sprint
	var direction := Input.get_axis("move_left2", "move_right2")
	var sprinting := Input.is_action_pressed("sprint2") and is_on_floor() and direction != 0
	current_speed = SPEED * 2 if sprinting else SPEED

	# Flip sprite
	if direction > 0:
		animated_sprite.flip_h = true
		$CollisionPolygon2D.scale.x = -1
	elif direction < 0:
		animated_sprite.flip_h = false
		$CollisionPolygon2D.scale.x = 1

	# Movement
	if direction:
		velocity.x = direction * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)

	move_and_slide()

	# "Moved" = pressed a direction or jumped
	if direction != 0 or Input.is_action_just_pressed("jump2"):
		GameState.last_moved = self

	z_index = 1 if GameState.last_moved == self else 0

	# Animation
	if not is_on_floor():
		if animated_sprite.animation != "jump2":
			animated_sprite.animation = "jump2"
		animated_sprite.pause()

		var last_frame := animated_sprite.sprite_frames.get_frame_count("jump2") - 1
		var hold := mini(HOLD_FRAME, last_frame)
		var v := velocity.y

		if v < 0.0:
			# Rising: frame 0 up to the hold frame at the peak
			var t := clampf(inverse_lerp(JUMP_VELOCITY, 0.0, v), 0.0, 1.0)
			animated_sprite.frame = roundi(lerpf(0, hold, t))
		elif v < FALL_HOLD_SPEED:
			# Falling, still slow: stay on the hold frame
			animated_sprite.frame = hold
		else:
			# Falling fast: hold frame on to the last frame
			var t := clampf(inverse_lerp(FALL_HOLD_SPEED, -JUMP_VELOCITY, v), 0.0, 1.0)
			animated_sprite.frame = roundi(lerpf(hold, last_frame, t))
	elif sprinting:
		animated_sprite.play("sprint2")
	else:
		animated_sprite.play("idle2")
