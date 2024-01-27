extends CharacterBody3D

signal died
signal position_updated(position: Vector3)
signal throw_water_balloon(
	water_balloon_scene: PackedScene, position: Vector3, linear_velocity: Vector3
)
signal hit_cymbals(cymbals_aoe: CymbalsAoe)

const SPEED = 5.0
const WATER_BALLOON_THROW_OFFSET = Vector3.ZERO
const WATER_BALLOON_THROW_VELOCITY = 7
const CYMBALS_RADIUS = 4
const CYMBALS_CONVERT_CHANCE = 0.8

var texture_down = preload("res://assets/sprites/clown/clown_down.png")
var texture_left = preload("res://assets/sprites/clown/clown_left.png")
var texture_right = preload("res://assets/sprites/clown/clown_right.png")
var texture_up = preload("res://assets/sprites/clown/clown_up.png")
var texture_left_up = preload("res://assets/sprites/clown/clown_up_left.png")
var texture_right_up = preload("res://assets/sprites/clown/clown_up_right.png")
var texture_left_down = preload("res://assets/sprites/clown/clown_down_left.png")
var texture_right_down = preload("res://assets/sprites/clown/clown_down_right.png")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var water_balloon_scene = preload("res://objects/water_balloon/water_balloon.tscn")
var cymbals_aoe_scene = preload("res://objects/cymbals/cymbals_aoe.tscn")


func _get_mouse_3d_position() -> Vector3:
	var camera = get_viewport().get_camera_3d()
	var space_state = get_world_3d().direct_space_state
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_end = ray_origin + camera.project_ray_normal(mouse_pos) * 1000
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var intersection_dict = space_state.intersect_ray(query)
	var intersection = intersection_dict["position"] if intersection_dict.size() > 0 else null
	return intersection


func _use_ability_1():
	var mouse_3d_position = _get_mouse_3d_position()
	if not mouse_3d_position:
		return
	var balloon_position = self.position + WATER_BALLOON_THROW_OFFSET
	var direction_vector = mouse_3d_position - self.position
	var direction_vector_2d_flat_normalized = (
		Vector3(direction_vector.x, 0, direction_vector.z).normalized()
	)
	var balloon_linear_velocity = (
		(
			Vector3(direction_vector_2d_flat_normalized.x, 1, direction_vector_2d_flat_normalized.z)
			. normalized()
		)
		* WATER_BALLOON_THROW_VELOCITY
	)
	throw_water_balloon.emit(water_balloon_scene, balloon_position, balloon_linear_velocity)


func _use_ability_2():
	var cymbals_aoe = cymbals_aoe_scene.instantiate()
	cymbals_aoe.position = self.position
	cymbals_aoe.set_radius(self.CYMBALS_RADIUS)
	if GlobalState.debug:
		var debug_sphere = CSGSphere3D.new()
		debug_sphere.radius = self.CYMBALS_RADIUS
		cymbals_aoe.add_child(debug_sphere)
	hit_cymbals.emit(cymbals_aoe)


func _handle_abilities():
	if Input.is_action_just_pressed("use_ability_1"):
		_use_ability_1()
	if Input.is_action_just_pressed("use_ability_2"):
		_use_ability_2()


func _physics_process(delta):
	position_updated.emit(position)
	if Input.is_action_just_pressed("menu"):
		died.emit()
		return

	if Input.is_action_just_pressed("toggle_debug"):
		GlobalState.toggle_debug()

	_handle_abilities()

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

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


func _process(_delta):
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
