extends Uniform
class_name ImageUniform

var texture : RID
var texture_size : Vector2i

static func create(image : Image) -> ImageUniform:
	var uniform := ImageUniform.new()
	uniform.texture = ComputeHelper.rd.texture_create(ComputeHelper.fmt, ComputeHelper.view, [image.get_data()])
	uniform.texture_size = image.get_size()
	return uniform

func get_rd_uniform(binding : int) -> RDUniform:
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	uniform.binding = binding
	uniform.add_id(texture)
	return uniform

func update(image : Image) -> void:
	if texture_size == image.get_size():
		ComputeHelper.rd.texture_update(texture, 0, image.get_data())
	else:
		ComputeHelper.rd.free_rid(texture)
		texture = ComputeHelper.rd.texture_create(ComputeHelper.fmt, ComputeHelper.view, [image.get_data()])
		texture_size = image.get_size()

func _exit_tree() -> void:
	ComputeHelper.rd.free_rid(texture)
