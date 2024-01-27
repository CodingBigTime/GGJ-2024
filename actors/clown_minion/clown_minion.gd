class_name ClownMinion
extends CharacterBody3D

signal died(clown_minion: ClownMinion)

enum State { IDLE, WONDER, FOLLOW, ATTACK }

const WONDER_SPEED = 2.0
const FOLLOW_SPEED = 6.0
const FOLLOW_DISTANCE = 7.0
const DESPAWN_DISTANCE = 20.0

const TEXTURES = {
	"normal_up": preload("res://assets/sprites/clownie/clownie_up.png"),
	"normal_down": preload("res://assets/sprites/clownie/clownie_down.png"),
	"left_normal": preload("res://assets/sprites/clownie/clownie_left.png"),
	"right_normal": preload("res://assets/sprites/clownie/clownie_right.png"),
	"left_up": preload("res://assets/sprites/clownie/clownie_left_up.png"),
	"right_up": preload("res://assets/sprites/clownie/clownie_up_right.png"),
	"left_down": preload("res://assets/sprites/clownie/clownie_left_down.png"),
	"right_down": preload("res://assets/sprites/clownie/clownie_down_right.png"),
	"normal_normal": preload("res://assets/sprites/clownie/clownie_down.png"),
}
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var player_position := Vector3()
var current_target: Villager = null

var state = State.IDLE
@onready var current_state_timer: Timer = $StateTimer


func _update_player_pos(player_pos: Vector3):
	player_position = player_pos


func _ready():
	current_state_timer.timeout.connect(_on_current_state_timer_timeout)


func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	move_and_slide()


func _process(delta):
	$Sprite3D.texture = TEXTURES[ActorUtils.get_movement_string(Vector2(velocity.x, velocity.z))]


func _on_current_state_timer_timeout():
	var distance_to_player = self.position.distance_to(player_position)
	if distance_to_player > self.DESPAWN_DISTANCE:
		queue_free()
	elif distance_to_player > self.FOLLOW_DISTANCE:
		# If the player is close enough, change to flee state
		state = State.FOLLOW
	elif (
		is_instance_valid(self.current_target)
		and not self.current_target.is_queued_for_deletion()
		and self.current_target != null
	):
		# If there is a target, change to attack state
		state = State.ATTACK
	else:
		# Otherwise, alternate between idle and wonder states
		match state:
			State.IDLE:
				if randf() > 0.2:
					# Go to wonder state and choose a new random direction
					state = State.WONDER
					var random_angle = randf_range(0, 2 * PI)
					var direction = Vector3(cos(random_angle), 0, sin(random_angle))
					self.velocity = direction * WONDER_SPEED
				else:
					# Continue to idle for longer
					state = State.IDLE
			State.WONDER:
				if randf() > 0.8:
					# Chance to go to idle state
					state = State.IDLE
				else:
					# Continue to wonder in the same direction
					state = State.WONDER
			State.FOLLOW:
				if randf() > 0.5:
					# Continue to flee even if out of range
					state = State.FOLLOW
				else:
					# Stop fleeing and go to idle state
					state = State.IDLE
			State.ATTACK:
				state = State.IDLE

	match state:
		State.IDLE:
			# Stop moving
			self.velocity = Vector3()
		State.FOLLOW:
			# Move away from the player
			var direction = player_position - self.position
			direction = direction.normalized()
			self.velocity = direction * WONDER_SPEED
		State.ATTACK:
			# Move towards the target
			if is_instance_valid(self.current_target):
				var direction = self.current_target.position - self.position
				direction = direction.normalized()
				self.velocity = direction * WONDER_SPEED
			else:
				state = State.IDLE
				self.velocity = Vector3()


func _on_lifetime_timer_timeout():
	died.emit(self)
	queue_free()


func replace_target_if_higher_priority(new_target: Villager):
	if not is_instance_valid(new_target) or new_target.is_queued_for_deletion():
		return
	if self.current_target == null:
		self.current_target = new_target
		self.current_target.died.connect(_target_died)
		return
	if (
		self.position.distance_squared_to(new_target.position)
		< self.position.distance_squared_to(self.current_target.position)
	):
		self.current_target = new_target
		self.current_target.died.connect(_target_died)


func _on_detection_area_3d_body_entered(body: Node3D):
	if not body.is_in_group("villager"):
		return
	replace_target_if_higher_priority(body)


func find_new_target():
	var bodies = $DetectionArea3D.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("villager"):
			replace_target_if_higher_priority(body)


func _target_died():
	self.current_target = null
	find_new_target()


func _on_convert_area_3d_body_entered(body: Node3D):
	if not body.is_in_group("villager"):
		return
	body.die()
	self.current_target = null
	find_new_target()
