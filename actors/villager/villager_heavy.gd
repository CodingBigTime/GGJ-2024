extends Villager

signal slam_player(damage: float)

enum SlamBobDirection { UP, DOWN }

const SLAM_DAMAGE := 5.0
const SLAM_RADIUS := 5.0
const ATTACK_TIME := 1.0
const SLAM_BOB_AMOUNT := 20.0
var is_attacking: bool = false
var current_bob_amount: float = 0.0
var target_bob_amount: float = 0.0
var slam_bob_direction: SlamBobDirection = SlamBobDirection.UP


func _start_bobbing():
	self.current_bob_amount = 0.0
	self.target_bob_amount = self.SLAM_BOB_AMOUNT
	self.slam_bob_direction = SlamBobDirection.UP
	self.is_attacking = true


func _attack():
	# Start a delayed attack
	$AttackTimer.start(self.ATTACK_TIME)
	self._start_bobbing()
	# TODO: Play attack animation


func _process(delta: float):
	self.update_texture()
	if self.is_attacking:
		var sprite: Sprite3D = $Sprite3D
		sprite.offset.y -= self.current_bob_amount
		self.current_bob_amount = lerp(
			self.current_bob_amount,
			self.target_bob_amount,
			(
				self.ATTACK_TIME
				* delta
				* (20.0 if self.slam_bob_direction == SlamBobDirection.DOWN else 5.5)
			)
		)
		sprite.offset.y += self.current_bob_amount
		if self.current_bob_amount <= 0.0:
			self.is_attacking = false
			self.slam_bob_direction = SlamBobDirection.UP
			sprite.offset.y -= self.current_bob_amount
		elif abs(self.current_bob_amount - self.target_bob_amount) < 0.1:
			self.slam_bob_direction = SlamBobDirection.DOWN
			self.target_bob_amount = 0.0


func _on_attack_timer_timeout():
	if self.position.distance_to(self.player_position) < self.SLAM_RADIUS:
		self.slam_player.emit(SLAM_DAMAGE)
	if GlobalState.debug:
		var debug_sphere = CSGSphere3D.new()
		debug_sphere.radius = self.SLAM_RADIUS
		debug_sphere.position = self.position
		get_parent().add_child(debug_sphere)
	$HeavyAttackParticles.one_shot = true
	$HeavyAttackParticles.emitting = true
