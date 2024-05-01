extends Uniform
class_name SharedImageUniform

var texture : RID
var texture_size : Vector2i
var image_format : Image.Format
var base_image_uniform : ImageUniform

static func create(image_uniform : ImageUniform) -> SharedImageUniform:
	var uniform := SharedImageUniform.new()
	uniform.texture = ComputeHelper.rd.texture_create_shared(ComputeHelper.view, image_uniform.texture)
	uniform.texture_size = image_uniform.texture_size
	uniform.image_format = image_uniform.image_format
	uniform.base_image_uniform = image_uniform
	uniform.base_image_uniform.rid_updated.connect(uniform.update_uniform)
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
	image_format = image_uniform.image_format
	if base_image_uniform != image_uniform:
		base_image_uniform.rid_updated.disconnect(update_uniform)
		base_image_uniform = image_uniform
		base_image_uniform.rid_updated.connect(update_uniform)

func get_image() -> Image:
	var image_data := ComputeHelper.rd.texture_get_data(texture, 0)
	return Image.create_from_data(texture_size.x, texture_size.y, false, image_format, image_data)

func _notification(what : int) -> void:
	if what == NOTIFICATION_PREDELETE:
		ComputeHelper.rd.free_rid(texture)
