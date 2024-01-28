class_name ClownMinion
extends CharacterBody3D

signal died(clown_minion: ClownMinion)

enum State { IDLE, WANDER, FOLLOW, ATTACK, CONVERT }

const WANDER_SPEED = 2.0
const FOLLOW_SPEED = 6.0
const ATTACK_SPEED = 6.0
const FOLLOW_DISTANCE = 5.0
const ATTACK_STOP_DISTANCE = 6.0
const DESPAWN_DISTANCE = 50.0

const TEXTURES = {
	"normal_up": preload("res://assets/sprites/clownie/clownie_up.png"),
	"normal_down": preload("res://assets/sprites/clownie/clownie_down.png"),
	"left_normal": preload("res://assets/sprites/clownie/clownie_left.png"),
	"right_normal": preload("res://assets/sprites/clownie/clownie_right.png"),
	"left_up": preload("res://assets/sprites/clownie/clownie_left_up.png"),
	"right_up": preload("res://assets/sprites/clownie/clownie_up_right.png"),
	"left_down": preload("res://assets/sprites/clownie/clownie_left_down.png"),
	"right_down": preload("res://assets/sprites/clownie/clownie_down_right.png"),
}
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var player_position := Vector3.ZERO
var current_target: Villager = null

var state: State = State.IDLE
@onready var current_state_timer: Timer = $StateTimer
@onready var debug_label: Label3D = $DebugLabel3D


func _update_player_pos(player_pos: Vector3):
	player_position = player_pos


func _ready():
	current_state_timer.timeout.connect(_on_current_state_timer_timeout)


func _physics_process(delta: float):
	if not is_on_floor():
		velocity.y -= gravity * delta

	move_and_slide()
	self.position.y = min(2, self.position.y)


func _process(_delta: float):
	$Sprite3D.texture = TEXTURES[ActorUtils.get_movement_string(Vector2(velocity.x, velocity.z))]
	if GlobalState.debug:
		self.debug_label.visible = true
	else:
		self.debug_label.visible = false


func set_state(new_state: State):
	match [new_state, self.state]:
		[State.IDLE, ..]:
			# Stop moving
			self.velocity = Vector3.ZERO
		[State.FOLLOW, ..]:
			# Move away from the player
			var direction = (self.player_position - self.position).normalized()
			self.velocity = direction * self.FOLLOW_SPEED
		[State.WANDER, State.WANDER]:
			# Continue moving in the same direction, update speed
			var direction = self.velocity.normalized()
			self.velocity = direction * WANDER_SPEED
		[State.WANDER, ..]:
			# Choose a new random direction
			var random_angle = randf_range(0, 2 * PI)
			var direction = Vector3(cos(random_angle), 0, sin(random_angle))
			self.velocity = direction * WANDER_SPEED
		[State.ATTACK, ..]:
			# Move towards the target
			if is_instance_valid(self.current_target):
				var direction = self.current_target.position - self.position
				direction = direction.normalized()
				self.velocity = direction * self.ATTACK_SPEED
			else:
				self.set_state(State.IDLE)
		[State.CONVERT, ..]:
			# Stop moving, play conversion animation
			self.velocity = Vector3()
			# TODO: Add conversion effect (laughing clown minion?)
	self.state = new_state
	self.debug_label.text = State.find_key(self.state)


func _on_current_state_timer_timeout():
	var distance_to_player = self.position.distance_to(self.player_position)
	if distance_to_player > self.DESPAWN_DISTANCE:
		queue_free()
		return

	find_new_target()

	if not is_instance_valid(self.current_target) or self.current_target.is_queued_for_deletion():
		self.current_target = null

	var self_out_of_follow_range = distance_to_player > self.FOLLOW_DISTANCE
	var self_out_of_attack_range = distance_to_player > self.ATTACK_STOP_DISTANCE
	var target_can_be_attacked = (
		self.current_target != null
		and (
			self.current_target.marked_for_attack
			or (
				self.current_target.position.distance_to(self.player_position)
				< self.ATTACK_STOP_DISTANCE
			)
		)
	)

	if self.state != State.ATTACK and self_out_of_follow_range and not target_can_be_attacked:
		# If the player is out of range and not attacking a villager, change to follow state
		self.set_state(State.FOLLOW)
	elif self.current_target != null and target_can_be_attacked:
		# If there is a target and it is attackable, change to attack state
		self.set_state(State.ATTACK)
	elif self_out_of_attack_range:
		# If the player is even further out of range even when attacking a villager
		# change to follow state
		self.set_state(State.FOLLOW)
	elif self.state in [State.IDLE, State.CONVERT]:
		# Go to WANDER state
		self.set_state(State.WANDER)
	elif self.state == State.WANDER:
		if randf() > 0.8:
			# Chance to go to idle state
			self.set_state(State.IDLE)
		else:
			# Continue to WANDER in the same direction
			self.set_state(State.WANDER)
	elif self.state == State.FOLLOW:
		if distance_to_player < 1 or randf() > 0.5:
			# Stop following and go to idle state
			self.set_state(State.IDLE)
		else:
			# Continue to follow even if out of range
			self.set_state(State.FOLLOW)
	elif self.state == State.ATTACK:
		self.set_state(State.IDLE)


func _on_lifetime_timer_timeout():
	died.emit(self)
	queue_free()


func _set_current_target(new_target: Villager):
	self.current_target = new_target


func replace_target_if_higher_priority(new_target: Villager):
	if not is_instance_valid(new_target) or new_target.is_queued_for_deletion():
		# If the new target is invalid, skip it
		return
	if (
		not new_target.marked_for_attack
		and new_target.position.distance_to(self.player_position) > self.ATTACK_STOP_DISTANCE
	):
		# If the new target is not marked for attack and is out of player range, skip it
		return
	if (
		self.current_target == null
		or not is_instance_valid(self.current_target)
		or self.current_target.is_queued_for_deletion()
	):
		# If there is no current target, prioritize the new target
		self._set_current_target(new_target)
		return
	if new_target.marked_for_attack and not self.current_target.marked_for_attack:
		# If the new target is marked for attack and the current target is not, prioritize the new target
		self._set_current_target(new_target)
	elif (
		new_target.marked_for_attack
		and self.current_target.marked_for_attack
		and (
			self.position.distance_squared_to(new_target.position)
			< self.position.distance_squared_to(self.current_target.position)
		)
	):
		# If both targets are marked for attack, prioritize the new target if it is closer
		self._set_current_target(new_target)
	elif (
		self.position.distance_squared_to(new_target.position)
		< self.position.distance_squared_to(self.current_target.position)
	):
		# If the new target is not marked for attack and is closer, prioritize the new target
		self._set_current_target(new_target)


func _on_detection_area_3d_body_entered(body: Node3D):
	if not body.is_in_group("villager"):
		return
	replace_target_if_higher_priority(body)


func find_new_target():
	var bodies = $DetectionArea3D.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("villager"):
			replace_target_if_higher_priority(body)


func _on_convert_area_3d_body_entered(body: Node3D):
	if not body.is_in_group("villager"):
		return
	body.die()
	self.current_target = null
	self.set_state(State.CONVERT)
	current_state_timer.start(0.5)
