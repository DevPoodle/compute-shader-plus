@tool
extends Object
class_name ComputeHelper
## Responsible for creating and running compute shaders.

static var rd := RenderingServer.get_rendering_device() ## The global [RenderingDevice].
static var view := RDTextureView.new() ## A default [RDTextureView] used internally by [ImageUniform].

var compute_shader : RID ## The [RID] of the shader specified in [method create].
var pipeline : RID ## The [RID] of the compute pipeline.
var uniforms : Array[Uniform] ## An array of every bound [Uniform].

## Returns a new ComputeHelper object that uses the shader provided by [param shader_path].
static func create(shader_path : String) -> ComputeHelper:
	var compute_helper := ComputeHelper.new()
	var shader_file := load(shader_path)
	var shader_spirv : RDShaderSPIRV = shader_file.get_spirv()
	
	compute_helper.compute_shader = rd.shader_create_from_spirv(shader_spirv)
	compute_helper.pipeline = rd.compute_pipeline_create(compute_helper.compute_shader)
	
	return compute_helper

## This function waits until all compute shaders currently running have finished. [b]Warning:[/b] To be deleted in Godot 4.3.
static func sync() -> void:
	rd.barrier(RenderingDevice.BARRIER_MASK_COMPUTE)

## Binds the given [param uniform]. The binding location depends on the order in which uniforms are added, starting at 0.
func add_uniform(uniform : Uniform) -> void:
	uniforms.append(uniform)

## Binds all uniforms in the [param uniform_array]. Binding order is the same as the order of the array.
func add_uniform_array(uniform_array : Array[Uniform]) -> void:
	uniforms.append_array(uniform_array)

## Runs the compute shader using the amount of [param groups].
func run(groups : Vector3i) -> void:
	var bindings : Array[RDUniform] = []
	for uniform_index in uniforms.size():
		bindings.append(uniforms[uniform_index].get_rd_uniform(uniform_index))
	
	var uniform_set := rd.uniform_set_create(bindings, compute_shader, 0)
	var compute_list := rd.compute_list_begin()
	
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_dispatch(compute_list, groups.x, groups.y, groups.z)
	rd.compute_list_end()
	rd.free_rid(uniform_set)

func _notification(what : int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if compute_shader.is_valid():
			rd.free_rid(compute_shader)
		if rd.compute_pipeline_is_valid(pipeline):
			rd.free_rid(pipeline)
		for uniform in uniforms:
			uniform.free()
