extends StorageBufferUniform
class_name UniformBufferUniform
## [Uniform] corresponding to arbitrary data.

## Returns a new UniformBufferUniform object using the given [param data].
static func create(data: PackedByteArray) -> UniformBufferUniform:
	while data.size() % 16 != 0:
		data.append(0)
	
	var uniform := UniformBufferUniform.new()
	uniform.storage_buffer_size = data.size()
	uniform.storage_buffer = ComputeHelper.rd.uniform_buffer_create(uniform.storage_buffer_size, data)
	return uniform

## UniformBufferUniform's custom implementation of [method Uniform.get_rd_uniform].
func get_rd_uniform(binding: int) -> RDUniform:
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER
	uniform.binding = binding
	uniform.add_id(storage_buffer)
	return uniform

## Updates the currently stored data to match the given [param data].
func update_data(data: PackedByteArray) -> void:
	while data.size() % 16 != 0:
		data.append(0)
	
	if storage_buffer_size == data.size():
		ComputeHelper.rd.buffer_update(storage_buffer, 0, storage_buffer_size, data)
	else:
		ComputeHelper.rd.free_rid(storage_buffer)
		storage_buffer_size = data.size()
		storage_buffer = ComputeHelper.rd.uniform_buffer_create(storage_buffer_size, data)
		rid_updated.emit(self)
