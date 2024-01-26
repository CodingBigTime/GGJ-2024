extends CharacterBody3D

signal died
signal position_signal(position: Vector3)

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var texture_down = load("res://assets/sprites/clown/clown_down.png")
var texture_left = load("res://assets/sprites/clown/clown_left.png")
var texture_right = load("res://assets/sprites/clown/clown_right.png")
var texture_up = load("res://assets/sprites/clown/clown_up.png")
var texture_left_up = load("res://assets/sprites/clown/clown_up_left.png")
var texture_right_up = load("res://assets/sprites/clown/clown_up_right.png")
var texture_left_down = load("res://assets/sprites/clown/clown_down_left.png")
var texture_right_down = load("res://assets/sprites/clown/clown_down_right.png")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
	position_signal.emit(position)
	if Input.is_action_just_pressed("menu"):
		died.emit()

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func _process(delta):
	# Change the player image based on the direction.
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if input_dir.x < 0:
		if input_dir.y < 0:
			$Sprite3D.texture = texture_left_up
		elif input_dir.y > 0:
			$Sprite3D.texture = texture_left_down
		else:
			$Sprite3D.texture = texture_left
	elif input_dir.x > 0:
		if input_dir.y < 0:
			$Sprite3D.texture = texture_right_up
		elif input_dir.y > 0:
			$Sprite3D.texture = texture_right_down
		else:
			$Sprite3D.texture = texture_right
	else:
		if input_dir.y < 0:
			$Sprite3D.texture = texture_up
		else:
			$Sprite3D.texture = texture_down
