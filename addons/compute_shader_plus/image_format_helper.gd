extends Object
class_name ImageFormatHelper
## Helper class for working with [RDTextureFormat]s and [enum RenderingDevice.DataFormat]s.

const image_format_to_data_format_array: Array[RenderingDevice.DataFormat] = [
	# Based on https://github.com/godotengine/godot/blob/master/servers/rendering/renderer_rd/storage_rd/texture_storage.cpp and _validate_texture_format()
	RenderingDevice.DATA_FORMAT_R8_UNORM,                  #  0 FORMAT_L8
	RenderingDevice.DATA_FORMAT_R8G8_UNORM,                #  1 FORMAT_LA8
	RenderingDevice.DATA_FORMAT_R8_UNORM,                  #  2 FORMAT_R8
	RenderingDevice.DATA_FORMAT_R8G8_UNORM,                #  3 FORMAT_RG8
	RenderingDevice.DATA_FORMAT_R8G8B8_UNORM,              #  4 FORMAT_RGB8
	RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM,            #  5 FORMAT_RGBA8
	RenderingDevice.DATA_FORMAT_R4G4B4A4_UNORM_PACK16,     #  6 FORMAT_RGBA4444
	RenderingDevice.DATA_FORMAT_R5G6B5_UNORM_PACK16,       #  7 FORMAT_RGB565
	RenderingDevice.DATA_FORMAT_R32_SFLOAT,                #  8 FORMAT_RF
	RenderingDevice.DATA_FORMAT_R32G32_SFLOAT,             #  9 FORMAT_RGF
	RenderingDevice.DATA_FORMAT_R32G32B32_SFLOAT,          # 10 FORMAT_RGBF
	RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT,       # 11 FORMAT_RGBAF
	RenderingDevice.DATA_FORMAT_R16_SFLOAT,                # 12 FORMAT_RH
	RenderingDevice.DATA_FORMAT_R16G16_SFLOAT,             # 13 FORMAT_RGH
	RenderingDevice.DATA_FORMAT_R16G16B16_SFLOAT,          # 14 FORMAT_RGBH
	RenderingDevice.DATA_FORMAT_R16G16B16A16_SFLOAT,       # 15 FORMAT_RGBAH
	RenderingDevice.DATA_FORMAT_E5B9G9R9_UFLOAT_PACK32,    # 16 FORMAT_RGBE9995
	RenderingDevice.DATA_FORMAT_BC1_RGB_UNORM_BLOCK,       # 17 FORMAT_DXT1
	RenderingDevice.DATA_FORMAT_BC2_UNORM_BLOCK,           # 18 FORMAT_DXT3
	RenderingDevice.DATA_FORMAT_BC3_UNORM_BLOCK,           # 19 FORMAT_DXT5
	RenderingDevice.DATA_FORMAT_BC4_UNORM_BLOCK,           # 20 FORMAT_RGTC_R
	RenderingDevice.DATA_FORMAT_BC5_UNORM_BLOCK,           # 21 FORMAT_RGTC_RG
	RenderingDevice.DATA_FORMAT_BC7_UNORM_BLOCK,           # 22 FORMAT_BPTC_RGBA
	RenderingDevice.DATA_FORMAT_BC6H_SFLOAT_BLOCK,         # 23 FORMAT_BPTC_RGBF
	RenderingDevice.DATA_FORMAT_BC6H_UFLOAT_BLOCK,         # 24 FORMAT_BPTC_RGBFU
	RenderingDevice.DATA_FORMAT_ETC2_R8G8B8_UNORM_BLOCK,   # 25 FORMAT_ETC
	RenderingDevice.DATA_FORMAT_EAC_R11_UNORM_BLOCK,       # 26 FORMAT_ETC2_R11
	RenderingDevice.DATA_FORMAT_EAC_R11_SNORM_BLOCK,       # 27 FORMAT_ETC2_R11S
	RenderingDevice.DATA_FORMAT_EAC_R11G11_UNORM_BLOCK,    # 28 FORMAT_ETC2_RG11
	RenderingDevice.DATA_FORMAT_EAC_R11G11_SNORM_BLOCK,    # 29 FORMAT_ETC2_RG11S
	RenderingDevice.DATA_FORMAT_ETC2_R8G8B8_UNORM_BLOCK,   # 30 FORMAT_ETC2_RGB8
	RenderingDevice.DATA_FORMAT_ETC2_R8G8B8A8_UNORM_BLOCK, # 31 FORMAT_ETC2_RGBA8
	RenderingDevice.DATA_FORMAT_ETC2_R8G8B8A1_UNORM_BLOCK, # 32 FORMAT_ETC2_RGB8A1
	RenderingDevice.DATA_FORMAT_ETC2_R8G8B8A8_UNORM_BLOCK, # 33 FORMAT_ETC2_RA_AS_RG
	RenderingDevice.DATA_FORMAT_BC3_UNORM_BLOCK,           # 34 FORMAT_DXT5_RA_AS_RG
	RenderingDevice.DATA_FORMAT_ASTC_4x4_UNORM_BLOCK,      # 35 FORMAT_ASTC_4x4
	RenderingDevice.DATA_FORMAT_ASTC_4x4_UNORM_BLOCK,      # 36 FORMAT_ASTC_4x4_HDR
	RenderingDevice.DATA_FORMAT_ASTC_8x8_UNORM_BLOCK,      # 37 FORMAT_ASTC_8x8
	RenderingDevice.DATA_FORMAT_ASTC_8x8_UNORM_BLOCK,      # 38 FORMAT_ASTC_8x8_HDR
	# You might run into bugs using formats other than the standard RGBAF in shaders
]

## Returns a [enum RenderingDevice.DataFormat] corresponding to [param format].
static func convert_image_format_to_data_format(format: Image.Format) -> RenderingDevice.DataFormat:
	var data_format := RenderingDevice.DATA_FORMAT_MAX
	if int(format) < image_format_to_data_format_array.size():
		data_format = image_format_to_data_format_array[format]
	assert(data_format != RenderingDevice.DATA_FORMAT_MAX, "Invalid image format used")
	return data_format

## Returns an [RDTextureFormat] with the [param format] and [param resolution] specified.
static func create_rd_texture_format(format: Image.Format, resolution: Vector2i) -> RDTextureFormat:
	var texture_format := RDTextureFormat.new()
	texture_format.width = resolution.x
	texture_format.height = resolution.y
	texture_format.format = ImageFormatHelper.convert_image_format_to_data_format(format)
	texture_format.usage_bits = (
		RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT +
		RenderingDevice.TEXTURE_USAGE_STORAGE_BIT +
		RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT +
		RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT
	)
	return texture_format
