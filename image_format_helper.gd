extends Node
class_name ImageFormatHelper

static func convert_image_format_to_data_format(format : Image.Format) -> RenderingDevice.DataFormat:
	var data_format := RenderingDevice.DATA_FORMAT_MAX
	match format:
		Image.FORMAT_RGBA8:
			data_format = RenderingDevice.DATA_FORMAT_R8G8B8A8_UINT
		Image.FORMAT_RGBAF:
			data_format = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT
	assert(data_format != RenderingDevice.DATA_FORMAT_MAX, "Invalid image format used")
	return data_format

static func create_rd_texture_format(format : Image.Format, resolution : Vector2i) -> RDTextureFormat:
	var texture_format := RDTextureFormat.new()
	texture_format.width = resolution.x
	texture_format.height = resolution.y
	texture_format.format = ImageFormatHelper.convert_image_format_to_data_format(format)
	texture_format.usage_bits = (
		RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT +
		RenderingDevice.TEXTURE_USAGE_STORAGE_BIT +
		RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT
	)
	return texture_format
