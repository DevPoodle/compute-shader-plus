extends Uniform
class_name ImageUniform
## [Uniform] corresponding to a texture. Given to the shader as an image.

var texture: RID ## The [RID] of the corresponding texture. Used internally.
var texture_size: Vector2i ## The resolution of the texture.
var image_format: Image.Format ## The [enum Image.Format] of the texture.
var texture_format: RDTextureFormat ## The [RDTextureFormat] of the texture.

## Returns a new ImageUniform object using the given [param image].
static func create(image: Image) -> ImageUniform:
	var uniform := ImageUniform.new()
	uniform.texture_size = image.get_size()
	uniform.image_format = image.get_format()
	uniform.texture_format = ImageFormatHelper.create_rd_texture_format(uniform.image_format, uniform.texture_size)
	uniform.texture = ComputeHelper.rd.texture_create(uniform.texture_format, ComputeHelper.view, [image.get_data()])
	return uniform

## ImageUniform's custom implementation of [method Uniform.get_rd_uniform].
func get_rd_uniform(binding: int) -> RDUniform:
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	uniform.binding = binding
	uniform.add_id(texture)
	return uniform

## Updates the texture to match [param image].
func update_image(image: Image) -> void:
	if texture_size == image.get_size() and image_format == image.get_format():
		ComputeHelper.rd.texture_update(texture, 0, image.get_data())
	else:
		ComputeHelper.rd.free_rid(texture)
		image_format = image.get_format()
		texture_size = image.get_size()
		texture_format = ImageFormatHelper.create_rd_texture_format(image_format, texture_size)
		texture = ComputeHelper.rd.texture_create(texture_format, ComputeHelper.view, [image.get_data()])
		rid_updated.emit(self)

## Returns a new [Image] that has the data of the texture. [b]Warning:[/b] Getting data from the GPU is very slow.
func get_image() -> Image:
	var image_data := ComputeHelper.rd.texture_get_data(texture, 0)
	return Image.create_from_data(texture_size.x, texture_size.y, false, image_format, image_data)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		ComputeHelper.rd.free_rid(texture)
