extends Uniform
class_name ImageUniform

var texture : RID
var texture_size : Vector2i
var image_format : Image.Format
var texture_format : RDTextureFormat

signal rid_updated(image_uniform : ImageUniform)

static func create(image : Image) -> ImageUniform:
	var uniform := ImageUniform.new()
	uniform.texture_size = image.get_size()
	uniform.image_format = image.get_format()
	uniform.texture_format = ImageFormatHelper.create_rd_texture_format(uniform.image_format, uniform.texture_size)
	uniform.texture = ComputeHelper.rd.texture_create(uniform.texture_format, ComputeHelper.view, [image.get_data()])
	return uniform

func get_rd_uniform(binding : int) -> RDUniform:
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	uniform.binding = binding
	uniform.add_id(texture)
	return uniform

func update_image(image : Image) -> void:
	if texture_size == image.get_size() and image_format == image.get_format():
		ComputeHelper.rd.texture_update(texture, 0, image.get_data())
	else:
		ComputeHelper.rd.free_rid(texture)
		image_format = image.get_format()
		texture_size = image.get_size()
		texture_format = ImageFormatHelper.create_rd_texture_format(image_format, texture_size)
		texture = ComputeHelper.rd.texture_create(texture_format, ComputeHelper.view, [image.get_data()])
		rid_updated.emit(self)

func get_image() -> Image:
	var image_data := ComputeHelper.rd.texture_get_data(texture, 0)
	return Image.create_from_data(texture_size.x, texture_size.y, false, image_format, image_data)

func _notification(what : int) -> void:
	if what == NOTIFICATION_PREDELETE:
		ComputeHelper.rd.free_rid(texture)
