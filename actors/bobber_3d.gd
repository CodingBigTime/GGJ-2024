class_name Bobber3D
extends Timer

@export var sprite: Sprite3D
@export var physics_body: PhysicsBody3D
@export_range(0, 10) var bob_offset_amount = 5.0
@export_range(0, 10) var bob_lerp_factor = 5.0

var bobbed: bool = false
var current_bob: float = 0.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	self.sprite.offset.y = lerp(
		self.sprite.offset.y,
		self.current_bob,
		self.bob_lerp_factor * delta * self.physics_body.velocity.length()
	)


func _on_timeout():
	if self.physics_body.velocity.length_squared() < 0.1:
		return
	if self.bobbed:
		self.current_bob = 0.0
		self.bobbed = false
	else:
		self.current_bob = self.bob_offset_amount
		self.bobbed = true
