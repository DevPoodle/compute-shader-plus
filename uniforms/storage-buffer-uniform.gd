extends Uniform
class_name StorageBufferUniform

var storage_buffer : RID
var storage_buffer_size := 0

static func create(data : PackedByteArray) -> StorageBufferUniform:
	var uniform := StorageBufferUniform.new()
	uniform.storage_buffer_size = data.size()
	uniform.storage_buffer = ComputeHelper.rd.storage_buffer_create(uniform.storage_buffer_size, data)
	return uniform

func get_rd_uniform(binding : int) -> RDUniform:
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform.binding = binding
	uniform.add_id(storage_buffer)
	return uniform

func update_data(data : PackedByteArray) -> void:
	if storage_buffer_size == data.size():
		ComputeHelper.rd.buffer_update(storage_buffer, 0, storage_buffer_size, data)
	else:
		ComputeHelper.rd.free_rid(storage_buffer)
		storage_buffer_size = data.size()
		storage_buffer = ComputeHelper.rd.storage_buffer_create(storage_buffer_size, data)

func get_data() -> PackedByteArray:
	return ComputeHelper.rd.buffer_get_data(storage_buffer)

func _exit_tree() -> void:
	ComputeHelper.rd.free_rid(storage_buffer)
