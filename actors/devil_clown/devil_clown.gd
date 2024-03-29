class_name DevilClown
extends CharacterBody3D

signal died
signal position_updated(position: Vector3)
signal throw_water_balloon(water_balloon: WaterBalloon)
signal hit_cymbals(cymbals_aoe: CymbalsAoe)
signal power_change(new_power: float)
signal cursor_update(coordinates: Vector2)
signal input_method_update(input_method: InputMethod)

enum InputMethod {
	MOUSE,
	CONTROLLER,
}

const SPEED := 5.0
const WATER_BALLOON_THROW_OFFSET := Vector3.ZERO
const WATER_BALLOON_THROW_VELOCITY := 3.18
const CYMBALS_RADIUS := 4
const CYMBALS_CONVERT_CHANCE := 0.8

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var water_balloon_scene = preload("res://objects/water_balloon/water_balloon.tscn")
var cymbals_aoe_scene = preload("res://objects/cymbals/cymbals_aoe.tscn")
var power: float = 20
var last_cursor_position: Vector2 = Vector2.ZERO
var last_mouse_poision: Vector2 = Vector2.ZERO
var last_controller_position: Vector2 = Vector2.ZERO


func get_mouse_position() -> Vector2:
	return get_viewport().get_mouse_position()


func mouse_moved() -> bool:
	return self.last_mouse_poision != self.get_mouse_position()


func _get_scaled_viewport_size() -> Vector2:
	var viewport_transform: Transform2D = get_viewport().get_screen_transform()
	var viewport_scale: Vector2 = viewport_transform.get_scale()
	return -viewport_transform.origin / viewport_scale + get_viewport().size * 1.0 / viewport_scale


func get_controller_position() -> Vector2:
	var input_aim = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	var screen_size = _get_scaled_viewport_size()
	return screen_size / 2.0 + input_aim * screen_size.y / 2.0


func controller_moved() -> bool:
	return self.last_controller_position != self.get_controller_position()


func get_cursor_position() -> Vector2:
	# Priority mouse > controller > last position
	if mouse_moved():
		self.input_method_update.emit(InputMethod.MOUSE)
		return get_mouse_position()
	if controller_moved():
		self.input_method_update.emit(InputMethod.CONTROLLER)
		return get_controller_position()
	return self.last_cursor_position


func _get_mouse_3d_position():
	var camera = get_viewport().get_camera_3d()
	var space_state = get_world_3d().direct_space_state
	var mouse_pos = self.get_cursor_position()
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

	if not _try_boost(0.5):
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
	var water_balloon: Node3D = water_balloon_scene.instantiate()

	water_balloon.position = balloon_position
	water_balloon.linear_velocity = balloon_linear_velocity
	throw_water_balloon.emit(water_balloon)


func _use_ability_2():
	if not _try_boost(4):
		return

	AudioHandlerSingleton.play_sound("try_convert")

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


func _physics_process(delta: float):
	position_updated.emit(position)
	if Input.is_action_just_pressed("menu"):
		died.emit()
		return

	if Input.is_action_just_pressed("toggle_debug"):
		GlobalState.toggle_debug()

	self.cursor_update.emit(self.get_cursor_position())
	_handle_abilities()

	var speed := self.SPEED
	if GlobalState.debug and Input.is_action_pressed("sprint"):
		speed = self.SPEED * 2

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = transform.basis * Vector3(input_dir.x, 0, input_dir.y)
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

	self.last_cursor_position = self.get_cursor_position()
	self.last_mouse_poision = self.get_mouse_position()
	self.last_controller_position = self.get_controller_position()


func _process(_delta: float):
	# Change the player image based on the direction.
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	$Sprite3D.animation = ActorUtils.get_movement_string(input_dir)

	if input_dir != Vector2.ZERO:
		$Sprite3D.play()
	else:
		$Sprite3D.stop()
		$Sprite3D.frame = 0

	power_change.emit(power)


func use_power(cost: float) -> void:
	power -= cost
	power_change.emit(power)


func can_power_boost(cost: float) -> bool:
	return power >= cost


func _try_boost(cost: float) -> bool:
	if can_power_boost(cost):
		use_power(cost)
		return true
	return false


func update_power(new_power: float) -> void:
	self.power = clamp(new_power, 0, 20)
	power_change.emit(self.power)


func _on_body_entered_area(body: Node3D):
	if body.is_in_group("junk_items") and body.has_method("convert_power") and power < 20:
		update_power(power + body.convert_power())
		AudioHandlerSingleton.play_sound("power_up")
		body.queue_free()


func damage(amount: float) -> void:
	self.power -= amount
	AudioHandlerSingleton.play_sound("player_hurt")
	if self.power < 0:
		died.emit()
