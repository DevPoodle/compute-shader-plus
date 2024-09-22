extends StorageBufferUniform
class_name VertexBufferUniform
## [Uniform] corresponding to vertex data. Use this when you want to reuse the data as a vertex buffer.

## Returns a new VertexBufferUniform object using the given [param data].
static func create(data: PackedByteArray) -> VertexBufferUniform:
	var uniform := VertexBufferUniform.new()
	uniform.storage_buffer_size = data.size()
	uniform.storage_buffer = ComputeHelper.rd.vertex_buffer_create(uniform.storage_buffer_size, data, true)
	return uniform

## Swaps data between two VertexBufferUniform objects. Both parameters should be VertexBufferUniforms.
static func swap_buffers(storage_buffer_1: StorageBufferUniform, storage_buffer_2: StorageBufferUniform) -> void:
	if !storage_buffer_1.is_class("VertexBufferUniform") or !storage_buffer_2.is_class("VertexBufferUniform"):
		return
	
	var storage_buffer_1_rid := storage_buffer_1.storage_buffer
	var storage_buffer_1_size := storage_buffer_1.storage_buffer_size
	
	storage_buffer_1.storage_buffer = storage_buffer_2.storage_buffer
	storage_buffer_1.storage_buffer_size = storage_buffer_2.storage_buffer_size
	storage_buffer_2.storage_buffer = storage_buffer_1_rid
	storage_buffer_2.storage_buffer_size = storage_buffer_1_size
	
	storage_buffer_1.rid_updated.emit(storage_buffer_1)
	storage_buffer_2.rid_updated.emit(storage_buffer_2)

## Updates the currently stored data to match the given [param data].
func update_data(data: PackedByteArray) -> void:
	if storage_buffer_size == data.size():
		ComputeHelper.rd.buffer_update(storage_buffer, 0, storage_buffer_size, data)
	else:
		ComputeHelper.rd.free_rid(storage_buffer)
		storage_buffer_size = data.size()
		storage_buffer = ComputeHelper.rd.vertex_buffer_create(storage_buffer_size, data, true)
		rid_updated.emit(self)
