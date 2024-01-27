class_name Trigonometry


static func to_polar(cartasian_coordinates: Vector2) -> Vector2:
	var r = cartasian_coordinates.distance_to(Vector2.ZERO)
	var angle = atan2(cartasian_coordinates.y, cartasian_coordinates.x)
	return Vector2(r, angle)


static func to_cartasian(polar_coordinates: Vector2) -> Vector2:
	var x = polar_coordinates.x * cos(polar_coordinates.y)
	var y = polar_coordinates.x * sin(polar_coordinates.y)
	return Vector2(x, y)


static func are_segments_intersecting(
	start1: Vector2, end1: Vector2, start2: Vector2, end2: Vector2
) -> bool:
	var d = (end1.x - start1.x) * (end2.y - start2.y) - (end1.y - start1.y) * (end2.x - start2.x)
	if d == 0:
		return false
	var u = (
		((start2.x - start1.x) * (end2.y - start2.y) - (start2.y - start1.y) * (end2.x - start2.x))
		/ d
	)
	var v = (
		((start2.x - start1.x) * (end1.y - start1.y) - (start2.y - start1.y) * (end1.x - start1.x))
		/ d
	)
	return u > 0 and u < 1 and v > 0 and v < 1


static func distance_point_to_segment(
	point: Vector2, segment_start: Vector2, segment_end: Vector2
) -> float:
	var a = segment_end - segment_start
	var b = point - segment_start
	var t = b.dot(a) / a.dot(a)
	if t < 0:
		t = 0
	elif t > 1:
		t = 1
	var projection = segment_start + a * t
	return point.distance_to(projection)


static func clamp_vector_2d(vector: Vector2, max_magnitude: float) -> Vector2:
	var magnitude = vector.length()
	if magnitude > max_magnitude:
		return vector * (max_magnitude / magnitude)
	return vector


static func clamp_vector_3d(vector: Vector3, max_magnitude: float) -> Vector3:
	var magnitude = vector.length()
	if magnitude > max_magnitude:
		return vector * (max_magnitude / magnitude)
	return vector


static func align_with_y(xform: Transform3D, new_y: Vector3) -> Transform3D:
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform
