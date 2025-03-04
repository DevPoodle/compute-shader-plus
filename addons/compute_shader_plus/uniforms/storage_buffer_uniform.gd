extends Uniform
class_name StorageBufferUniform
## [Uniform] corresponding to arbitrary data.

var storage_buffer: RID ## The [RID] of the corresponding storage buffer. Used internally.
var storage_buffer_size := 0 ## The size of the data in bytes.

signal async_data_retrieved(data: PackedByteArray)

## Returns a new StorageBufferUniform object using the given [param data].
static func create(data: PackedByteArray) -> StorageBufferUniform:
	var uniform := StorageBufferUniform.new()
	uniform.storage_buffer_size = data.size()
	uniform.storage_buffer = ComputeHelper.rd.storage_buffer_create(uniform.storage_buffer_size, data)
	return uniform

## Swaps data between two StorageBufferUniform objects.
static func swap_buffers(storage_buffer_1: StorageBufferUniform, storage_buffer_2: StorageBufferUniform) -> void:
	var storage_buffer_1_rid := storage_buffer_1.storage_buffer
	var storage_buffer_1_size := storage_buffer_1.storage_buffer_size
	
	storage_buffer_1.storage_buffer = storage_buffer_2.storage_buffer
	storage_buffer_1.storage_buffer_size = storage_buffer_2.storage_buffer_size
	storage_buffer_2.storage_buffer = storage_buffer_1_rid
	storage_buffer_2.storage_buffer_size = storage_buffer_1_size
	
	storage_buffer_1.rid_updated.emit(storage_buffer_1)
	storage_buffer_2.rid_updated.emit(storage_buffer_2)

## StorageBufferUniform's custom implementation of [method Uniform.get_rd_uniform].
func get_rd_uniform(binding: int) -> RDUniform:
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform.binding = binding
	uniform.add_id(storage_buffer)
	return uniform

## Updates the currently stored data to match the given [param data].
func update_data(data: PackedByteArray) -> void:
	if storage_buffer_size == data.size():
		ComputeHelper.rd.buffer_update(storage_buffer, 0, storage_buffer_size, data)
	else:
		ComputeHelper.rd.free_rid(storage_buffer)
		storage_buffer_size = data.size()
		storage_buffer = ComputeHelper.rd.storage_buffer_create(storage_buffer_size, data)
		rid_updated.emit(self)

## Returns a [PackedByteArray] with the current data. [b]Warning:[/b] This can lead to performance issues.
func get_data() -> PackedByteArray:
	return ComputeHelper.rd.buffer_get_data(storage_buffer)

## Gets the buffer's data asynchronously. Returns a [Signal] with a [PackedByteArray] that will be emitted when the data is retrieved. The signal remains the same each time you call this function, so feel free to cache it. [b]Note:[\b] The delay to when the signal is emitted corresponds to the amount of frames specified by [member ProjectSettings.rendering/rendering_device/vsync/frame_queue_size]. Also, this function does nothing before Godot 4.4.
func get_data_async() -> Signal:
	if ComputeHelper.version < 4:
		return async_data_retrieved
	ComputeHelper.rd.buffer_get_data_async(storage_buffer, async_data_retrieved.emit)
	return async_data_retrieved

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		ComputeHelper.rd.free_rid(storage_buffer)
