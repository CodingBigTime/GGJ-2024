extends Villager

signal throw_tangerine(tangerine: Tangerine)

const TANGERINE_SCENE := preload("res://objects/tangerine/tangerine.tscn")
const TANGERINE_THROW_IMPULSE: float = 6


func _attack():
	var tangerine := TANGERINE_SCENE.instantiate()
	var direction_vector: Vector3 = (self.player_position - self.position).normalized()
	tangerine.position = self.position
	tangerine.apply_central_impulse(direction_vector * TANGERINE_THROW_IMPULSE)
	self.throw_tangerine.emit(tangerine)
	# TODO: Play attack animation
