extends Uniform
class_name SharedImageUniform

var texture : RID
var texture_size : Vector2i

static func create(image_uniform : ImageUniform) -> SharedImageUniform:
	var uniform := SharedImageUniform.new()
	uniform.texture = ComputeHelper.rd.texture_create_shared(ComputeHelper.view, image_uniform.texture)
	uniform.texture_size = image_uniform.texture_size
	return uniform

func get_rd_uniform(binding : int) -> RDUniform:
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	uniform.binding = binding
	uniform.add_id(texture)
	return uniform

func update(image_uniform : ImageUniform) -> void:
	texture = ComputeHelper.rd.texture_create_shared(ComputeHelper.view, image_uniform.texture)
	texture_size = image_uniform.texture_size

func _exit_tree() -> void:
	ComputeHelper.rd.free_rid(texture)
