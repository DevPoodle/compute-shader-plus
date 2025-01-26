@tool
extends Object
class_name ComputeHelper
## Responsible for creating and running compute shaders.

static var rd := RenderingServer.get_rendering_device() ## The global [RenderingDevice].
static var view := RDTextureView.new() ## A default [RDTextureView] used internally by [ImageUniform].
static var version: int = Engine.get_version_info()["minor"]

var compute_shader: RID ## The [RID] of the shader specified in [method create].
var pipeline: RID ## The [RID] of the compute pipeline.
var uniforms: Array[Uniform] ## An array of every bound [Uniform].
var uniform_set: RID ## The uniform set. Used internally.
var uniform_set_dirty := true ## Keeps track of whether the uniform set needs to be updated. Used internally.

## Returns a new ComputeHelper object that uses the shader provided by [param shader_path].
static func create(shader_path: String) -> ComputeHelper:
	var compute_helper := ComputeHelper.new()
	var shader_file: RDShaderFile = load(shader_path)
	var shader_spirv := shader_file.get_spirv()
	
	compute_helper.compute_shader = rd.shader_create_from_spirv(shader_spirv)
	compute_helper.pipeline = rd.compute_pipeline_create(compute_helper.compute_shader)
	
	return compute_helper

## This function waits until all compute shaders currently running have finished. Doesn't do anything in versions past 4.2.
static func sync() -> void:
	if version > 2:
		return
	rd.barrier(RenderingDevice.BARRIER_MASK_COMPUTE)

## Binds the given [param uniform]. The binding location depends on the order in which uniforms are added, starting at 0.
func add_uniform(uniform: Uniform) -> void:
	uniforms.append(uniform)
	uniform.rid_updated.connect(make_uniform_set_dirty)
	uniform_set_dirty = true

## Binds all uniforms in the [param uniform_array]. Binding order is the same as the order of the array.
func add_uniform_array(uniform_array: Array[Uniform]) -> void:
	uniforms.append_array(uniform_array)
	for uniform: Uniform in uniform_array:
		uniform.rid_updated.connect(make_uniform_set_dirty)
	uniform_set_dirty = true

## Runs the compute shader using the amount of [param groups]. [param push_constant] is optional and allows you to push extra data to the compute shader.
func run(groups: Vector3i, push_constant := PackedByteArray()) -> void:
	if uniform_set_dirty:
		var bindings: Array[RDUniform] = []
		for uniform_index in uniforms.size():
			bindings.append(uniforms[uniform_index].get_rd_uniform(uniform_index))
		if uniform_set.is_valid() and rd.uniform_set_is_valid(uniform_set):
			rd.free_rid(uniform_set)
		uniform_set = rd.uniform_set_create(bindings, compute_shader, 0)
		uniform_set_dirty = false
	var compute_list := rd.compute_list_begin()
	
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	
	if !push_constant.is_empty():
		while push_constant.size() % 16 != 0:
			push_constant.append(0)
		rd.compute_list_set_push_constant(compute_list, push_constant, push_constant.size())
	
	rd.compute_list_dispatch(compute_list, groups.x, groups.y, groups.z)
	rd.compute_list_end()

## Called from a bound uniform when it's RID changes.
func make_uniform_set_dirty(_uniform: Uniform) -> void:
	uniform_set_dirty = true

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if uniform_set.is_valid():
			rd.free_rid(uniform_set)
		if compute_shader.is_valid():
			rd.free_rid(compute_shader)
		if rd.compute_pipeline_is_valid(pipeline):
			rd.free_rid(pipeline)
