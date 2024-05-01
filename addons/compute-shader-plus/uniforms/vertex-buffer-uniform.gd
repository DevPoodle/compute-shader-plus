extends Uniform
class_name VertexBufferUniform

var vertex_buffer : RID
var vertex_buffer_size := 0

static func create(vertex_data : PackedByteArray) -> VertexBufferUniform:
	var uniform := VertexBufferUniform.new()
	uniform.vertex_buffer_size = vertex_data.size()
	uniform.vertex_buffer = ComputeHelper.rd.vertex_buffer_create(uniform.vertex_buffer_size, vertex_data, true)
	return uniform

func get_rd_uniform(binding : int) -> RDUniform:
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform.binding = binding
	uniform.add_id(vertex_buffer)
	return uniform

func _notification(what : int) -> void:
	if what == NOTIFICATION_PREDELETE:
		ComputeHelper.rd.free_rid(vertex_buffer)
