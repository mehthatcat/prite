extends CharacterBody2D

#real ones dont know what theyre doing

const SPEED = 200.0
const JUMP_VELOCITY = -1200.0
var current_speed

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animated_sprite.play("jump")
	
	# sprint IF I CAN GET IT TO WORK >:(
	if Input.is_action_pressed("sprint") and is_on_floor() and Input.is_action_pressed("move_left") or Input.is_action_pressed("sprint") and is_on_floor() and Input.is_action_pressed("move_right"):
		animated_sprite.play("sprint")
		current_speed = SPEED * 2
	else:
		animated_sprite.play("idle")
		current_speed = SPEED
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction > 0:
		animated_sprite.flip_h = true
	elif direction < 0:
		animated_sprite.flip_h = false
	
	if direction:
		velocity.x = direction * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)

	move_and_slide()
