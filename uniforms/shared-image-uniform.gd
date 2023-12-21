extends Uniform
class_name SharedImageUniform

var texture : RID
var texture_size : Vector2i
var texture_format : int

static func create(image_uniform : ImageUniform) -> SharedImageUniform:
	var uniform := SharedImageUniform.new()
	uniform.texture = ComputeHelper.rd.texture_create_shared(ComputeHelper.view, image_uniform.texture)
	uniform.texture_size = image_uniform.texture_size
	uniform.texture_format = image_uniform.texture_format
	return uniform

func get_rd_uniform(binding : int) -> RDUniform:
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	uniform.binding = binding
	uniform.add_id(texture)
	return uniform

func update_uniform(image_uniform : ImageUniform) -> void:
	texture = ComputeHelper.rd.texture_create_shared(ComputeHelper.view, image_uniform.texture)
	texture_size = image_uniform.texture_size
	texture_format = image_uniform.texture_format

func get_image() -> Image:
	var image_data := ComputeHelper.rd.texture_get_data(texture, 0)
	return Image.create_from_data(texture_size.x, texture_size.y, false, texture_format, image_data)

func _exit_tree() -> void:
	ComputeHelper.rd.free_rid(texture)
