extends StorageBufferUniform
class_name VertexBufferUniform
## [Uniform] corresponding to vertex data.
## Use this when you want to reuse the data as a vertex buffer.

## Returns a new VertexBufferUniform object using the given [param data].
static func create(data: PackedByteArray) -> VertexBufferUniform:
	var uniform := VertexBufferUniform.new()
	uniform.storage_buffer_size = data.size()
	if ComputeHelper.version < 4:
		uniform.storage_buffer = ComputeHelper.rd.vertex_buffer_create(data.size(), data, true)
	else:
		uniform.storage_buffer = ComputeHelper.rd.vertex_buffer_create(data.size(), data, 2)
	return uniform

## Swaps data between two VertexBufferUniform objects.
## Both parameters should be VertexBufferUniforms.
static func swap_buffers(buffer_1: StorageBufferUniform, buffer_2: StorageBufferUniform) -> void:
	if !buffer_1.is_class("VertexBufferUniform") or !buffer_2.is_class("VertexBufferUniform"):
		return
	
	var buffer_1_rid := buffer_1.storage_buffer
	var buffer_1_size := buffer_1.storage_buffer_size
	
	buffer_1.storage_buffer = buffer_2.storage_buffer
	buffer_1.storage_buffer_size = buffer_2.storage_buffer_size
	buffer_2.storage_buffer = buffer_1_rid
	buffer_2.storage_buffer_size = buffer_1_size
	
	buffer_1.rid_updated.emit(buffer_1)
	buffer_2.rid_updated.emit(buffer_2)

## Updates the currently stored data to match the given [param data].
func update_data(data: PackedByteArray) -> void:
	if storage_buffer_size == data.size():
		ComputeHelper.rd.buffer_update(storage_buffer, 0, storage_buffer_size, data)
	else:
		ComputeHelper.rd.free_rid(storage_buffer)
		storage_buffer_size = data.size()
		
		if ComputeHelper.version < 4:
			storage_buffer = ComputeHelper.rd.vertex_buffer_create(storage_buffer_size, data, true)
		else:
			storage_buffer = ComputeHelper.rd.vertex_buffer_create(storage_buffer_size, data, 2)
		
		rid_updated.emit(self)
