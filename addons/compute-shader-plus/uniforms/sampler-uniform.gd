extends ImageUniform
class_name SamplerUniform

var sampler : RID
var sampler_state : RDSamplerState

static func create(image : Image) -> SamplerUniform:
	var uniform := SamplerUniform.new()
	uniform.texture_size = image.get_size()
	uniform.image_format = image.get_format()
	uniform.texture_format = ImageFormatHelper.create_rd_texture_format(uniform.image_format, uniform.texture_size)
	uniform.texture = ComputeHelper.rd.texture_create(uniform.texture_format, ComputeHelper.view, [image.get_data()])
	uniform.sampler_state = RDSamplerState.new()
	uniform.sampler = ComputeHelper.rd.sampler_create(uniform.sampler_state)
	return uniform

func get_rd_uniform(binding : int) -> RDUniform:
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
	uniform.binding = binding
	uniform.add_id(sampler)
	uniform.add_id(texture)
	return uniform

func _notification(what : int) -> void:
	if what == NOTIFICATION_PREDELETE:
		ComputeHelper.rd.free_rid(sampler)
		ComputeHelper.rd.free_rid(texture)
