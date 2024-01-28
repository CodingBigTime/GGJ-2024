class_name ArrayUtil


static func intersect_i(array1, array2):
	var result = []
	for element in array1:
		if element in array2:
			result.push_back(element)
	return result


static func sum(array: Array):
	var result = 0
	for element in array:
		result += element
	return result
