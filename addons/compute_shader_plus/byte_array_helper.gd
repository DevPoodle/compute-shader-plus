extends Object
class_name ByteArrayHelper
## Helper class for converting [Array]s to [PackedByteArray]s that comply with GLSL formatting.

const alignment_sizes: Dictionary[int, int] = {
	TYPE_INT: 1, TYPE_FLOAT: 1,
	TYPE_VECTOR2: 2, TYPE_VECTOR2I: 2,
	TYPE_VECTOR3: 3, TYPE_VECTOR3I: 3,
	TYPE_VECTOR4: 4, TYPE_VECTOR4I: 4,
}

## Returns a [PackedByteArray] based on the data in [param array] that follows std430 packing.
static func array_to_bytes(array: Array) -> PackedByteArray:
	var bytes := PackedByteArray()
	var alignment := 0
	
	for element: Variant in array:
		var size := alignment_sizes[typeof(element)]
		while 4 - alignment < size:
			bytes.resize(bytes.size() + 4)
			alignment = (alignment + 1) % 4
		bytes.resize(bytes.size() + size * 4)
		alignment = (alignment + size) % 4
		
		match typeof(element):
			TYPE_INT:
				bytes.encode_u32(bytes.size() - 4, element)
			TYPE_FLOAT:
				bytes.encode_float(bytes.size() - 4, element)
			TYPE_VECTOR2, TYPE_VECTOR3, TYPE_VECTOR4:
				for i: int in size:
					bytes.encode_float(bytes.size() - 4 * (size - i), element[i])
			TYPE_VECTOR2I, TYPE_VECTOR3I, TYPE_VECTOR4I:
				for i: int in size:
					bytes.encode_s32(bytes.size() - 4 * (size - i), element[i])
			_:
				printerr("ByteArrayHelper tried to convert an unsupported type")
	return bytes
