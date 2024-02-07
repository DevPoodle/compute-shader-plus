extends Node
class_name ComputeHelper

static var rd := RenderingServer.get_rendering_device()
static var view := RDTextureView.new()

var compute_shader : RID
var pipeline : RID
var bindings : Array[RDUniform]
var uniforms : Array[Uniform]

static func create(shader_path : String) -> ComputeHelper:
	var compute_helper := ComputeHelper.new()
	var shader_file := load(shader_path)
	var shader_spirv : RDShaderSPIRV = shader_file.get_spirv()
	
	compute_helper.compute_shader = rd.shader_create_from_spirv(shader_spirv)
	compute_helper.pipeline = rd.compute_pipeline_create(compute_helper.compute_shader)
	
	return compute_helper

static func sync() -> void:
	rd.barrier(RenderingDevice.BARRIER_MASK_COMPUTE)

func add_uniform(uniform : Uniform) -> void:
	uniforms.append(uniform)

func add_uniform_array(uniform_array : Array[Uniform]) -> void:
	uniforms.append_array(uniform_array)

func run(groups : Vector3i) -> void:
	bindings.clear()
	for uniform_index in uniforms.size():
		bindings.append(uniforms[uniform_index].get_rd_uniform(uniform_index))
	
	var uniform_set := rd.uniform_set_create(bindings, compute_shader, 0)
	var compute_list := rd.compute_list_begin()
	
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_dispatch(compute_list, groups.x, groups.y, groups.z)
	rd.compute_list_end()

func _exit_tree() -> void:
	rd.free_rid(compute_shader)
	rd.free_rid(pipeline)
	for uniform in uniforms:
		uniform.queue_free()
