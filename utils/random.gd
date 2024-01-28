class_name Random


static func random_2d_rect_point(
	min_x: float = 0.0, max_x: float = 1.0, min_y: float = 0.0, max_y: float = 1.0
) -> Vector2:
	return Vector2(randf_range(min_x, max_x), randf_range(min_y, max_y))


static func random_2d_circle_point(min_distance: float = 0.0, max_distance: float = 1.0) -> Vector2:
	for i in range(1000):
		var point = random_2d_rect_point(-max_distance, max_distance, -max_distance, max_distance)
		var dist = point.length()
		if dist < min_distance or dist > max_distance:
			continue
		return point

	printerr("Failed to find a random point")
	return Vector2.ZERO


static func random_3d_rect_cube_point(
	min_x: float = 0.0,
	max_x: float = 1.0,
	min_y: float = 0.0,
	max_y: float = 1.0,
	min_z: float = 0.0,
	max_z: float = 1.0
) -> Vector3:
	return Vector3(randf_range(min_x, max_x), randf_range(min_y, max_y), randf_range(min_z, max_z))


static func random_3d_sphere_point(min_distance: float = 0.0, max_distance: float = 1.0) -> Vector3:
	for i in range(1000):
		var point = random_3d_rect_cube_point(
			-max_distance, max_distance, -max_distance, max_distance, -max_distance, max_distance
		)
		var dist = point.length()
		if dist < min_distance or dist > max_distance:
			continue
		return point

	printerr("Failed to find a random point")
	return Vector3.ZERO


static func random_3d_cylinder_point(
	min_radius: float = 0.0,
	max_radius: float = 1.0,
	min_height: float = 0.0,
	max_height: float = 1.0
) -> Vector3:
	for i in range(1000):
		var circle_point = random_2d_circle_point(min_radius, max_radius)
		var height = randf_range(min_height, max_height)
		return Vector3(circle_point.x, height, circle_point.y)

	printerr("Failed to find a random point")
	return Vector3.ZERO


static func random_from_array(array: Array):
	return array[randi_range(0, array.size() - 1)]


static func weighted_choice(choices: Array, weights: Array[float]):
	var running_sum := 0.0
	var random_value = randf_range(0.0, ArrayUtil.sum(weights))
	for i in range(weights.size()):
		var weight = weights[i]
		print(i, " ", weight, " ", weights.size())
		running_sum += weight
		if random_value <= running_sum:
			return choices[i]
		print(random_value, " -= VS =- ", running_sum)
	printerr("Failed to find a weighted choice")
	return choices[weights.find(weights.size() - 1)]
