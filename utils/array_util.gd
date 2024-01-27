class_name ArrayUtil


static func intersect_i(array1, array2):
	var result = []
	for element in array1:
		if element in array2:
			result.push_back(element)
	return result
