extends Uniform
class_name SharedImageUniform
## [Uniform] corresponding to a texture. Shares data with an [ImageUniform]. Given to the shader as an image.

var texture: RID ## The [RID] of the corresponding texture. Used internally.
var texture_size: Vector2i ## The resolution of the texture.
var base_image_uniform: ImageUniform ## The [ImageUniform] this uniform shares data with.

## Returns a new SharedImageUniform object using the given [param image_uniform].
static func create(image_uniform: ImageUniform) -> SharedImageUniform:
	var uniform := SharedImageUniform.new()
	uniform.texture = ComputeHelper.rd.texture_create_shared(ComputeHelper.view, image_uniform.texture)
	uniform.texture_size = image_uniform.texture_size
	uniform.base_image_uniform = image_uniform
	uniform.base_image_uniform.rid_updated.connect(uniform.update_uniform)
	return uniform

## SharedImageUniform's custom implementation of [method Uniform.get_rd_uniform].
func get_rd_uniform(binding: int) -> RDUniform:
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	uniform.binding = binding
	uniform.add_id(texture)
	return uniform

## Updates the base image uniform to match [param image_uniform].
func update_uniform(image_uniform: ImageUniform) -> void:
	texture = ComputeHelper.rd.texture_create_shared(ComputeHelper.view, image_uniform.texture)
	texture_size = image_uniform.texture_size
	rid_updated.emit(self)
	if base_image_uniform != image_uniform:
		base_image_uniform.rid_updated.disconnect(update_uniform)
		base_image_uniform = image_uniform
		base_image_uniform.rid_updated.connect(update_uniform)

## Returns a new [Image] that has the data of the texture. [b]Warning:[/b] Getting data from the GPU is very slow.
func get_image() -> Image:
	var image_data := ComputeHelper.rd.texture_get_data(texture, 0)
	return Image.create_from_data(texture_size.x, texture_size.y, false, base_image_uniform.image_format, image_data)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		ComputeHelper.rd.free_rid(texture)
