extends CharacterBody3D

signal died
signal position_updated(position: Vector3)
signal throw_water_balloon(
	water_balloon_scene: PackedScene, position: Vector3, linear_velocity: Vector3
)
signal hit_cymbals(cymbals_aoe: CymbalsAoe)
signal power_change(new_power: float)

const SPEED = 5.0
const WATER_BALLOON_THROW_OFFSET = Vector3.ZERO
const WATER_BALLOON_THROW_VELOCITY = 3.18
const CYMBALS_RADIUS = 4
const CYMBALS_CONVERT_CHANCE = 0.8

const TEXTURES = {
	"normal_up": preload("res://assets/sprites/clown/clown_up.png"),
	"normal_down": preload("res://assets/sprites/clown/clown_down.png"),
	"left_normal": preload("res://assets/sprites/clown/clown_left.png"),
	"right_normal": preload("res://assets/sprites/clown/clown_right.png"),
	"left_up": preload("res://assets/sprites/clown/clown_left_up.png"),
	"right_up": preload("res://assets/sprites/clown/clown_right_up.png"),
	"left_down": preload("res://assets/sprites/clown/clown_left_down.png"),
	"right_down": preload("res://assets/sprites/clown/clown_right_down.png"),
}

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var water_balloon_scene = preload("res://objects/water_balloon/water_balloon.tscn")
var cymbals_aoe_scene = preload("res://objects/cymbals/cymbals_aoe.tscn")
var power: float = 20


func _get_mouse_3d_position():
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
	var direction_vector_2d_flat = Vector3(direction_vector.x, 0, direction_vector.z)
	var direction_vector_2d_flat_normalized = direction_vector_2d_flat.normalized()
	var balloon_linear_velocity = (
		(
			Vector3(direction_vector_2d_flat_normalized.x, 1, direction_vector_2d_flat_normalized.z)
			. normalized()
		)
		* (WATER_BALLOON_THROW_VELOCITY * sqrt(direction_vector_2d_flat.length()))
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
		if check_power_boost_cost(0.2):
			_use_ability_1()
			use_power(0.2)
	if Input.is_action_just_pressed("use_ability_2"):
		if check_power_boost_cost(0.5):
			_use_ability_2()
			use_power(0.5)


func _physics_process(delta: float):
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
	var direction = transform.basis * Vector3(input_dir.x, 0, input_dir.y)
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func _process(_delta: float):
	# Change the player image based on the direction.
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	$Sprite3D.texture = TEXTURES[ActorUtils.get_movement_string(input_dir)]
	power_change.emit(power)


func use_power(cost: float) -> void:
	power -= cost
	power_change.emit(power)


func check_power_boost_cost(cost: float) -> bool:
	if power >= cost:
		return true
	return false


func _on_body_entered(body: Node3D):
	print(body)
	if body.is_in_group("junk_items") && body.texture == "branch":
		print(body)
		power += 5
		body.queue_free()
