extends Object
class_name ImageFormatHelper

const image_format_to_data_format_array : Array[RenderingDevice.DataFormat] = [
	RenderingDevice.DATA_FORMAT_R8_UINT,
	RenderingDevice.DATA_FORMAT_R8G8_UINT,
	RenderingDevice.DATA_FORMAT_R8_UINT,
	RenderingDevice.DATA_FORMAT_R8G8_UINT,
	RenderingDevice.DATA_FORMAT_R8G8B8_UINT,
	RenderingDevice.DATA_FORMAT_R8G8B8A8_UINT,
	RenderingDevice.DATA_FORMAT_R4G4B4A4_UNORM_PACK16,
	RenderingDevice.DATA_FORMAT_MAX, # RGB565 not supported
	RenderingDevice.DATA_FORMAT_R32_SFLOAT,
	RenderingDevice.DATA_FORMAT_R32G32_SFLOAT,
	RenderingDevice.DATA_FORMAT_R32G32B32_SFLOAT,
	RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT,
	RenderingDevice.DATA_FORMAT_R16_SFLOAT,
	RenderingDevice.DATA_FORMAT_R16G16_SFLOAT,
	RenderingDevice.DATA_FORMAT_R16G16B16_SFLOAT,
	RenderingDevice.DATA_FORMAT_R16G16B16A16_SFLOAT,
	## The rest are currently not supported
]

static func convert_image_format_to_data_format(format : Image.Format) -> RenderingDevice.DataFormat:
	var data_format := RenderingDevice.DATA_FORMAT_MAX
	if int(format) < image_format_to_data_format_array.size():
		data_format = image_format_to_data_format_array[format]
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
