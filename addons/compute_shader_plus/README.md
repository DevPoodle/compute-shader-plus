# Compute Shader Plus

This Godot 4 plugin adds in a ComputeHelper class that keeps track of compute shaders and their uniforms.
Here's a simple example of a shader that reads and then writes to a texture (ideally in the render thread):

	var image := Image.create(image_size.x, image_size.y, false, Image.FORMAT_RGBAF)
	image.fill(Color.BLACK)
	
	var compute_shader := ComputeHelper.create("res://compute-shader.glsl")
	var input_texture := ImageUniform.create(image)
	var output_texture := SharedImageUniform.create(input_texture)
	compute_shader.add_uniform_array([input_texture, output_texture])
	
	var work_groups := Vector3i(image_size.x, image_size.y, 1)
	compute_shader.run(work_groups)
	ComputeHelper.sync()
	
	image = output_texture.get_image()

Corresponding shader file:

	#[compute]
	#version 450
	
	layout(set = 0, binding = 0, rgba32f) readonly uniform image2D input_texture;
	layout(set = 0, binding = 1, rgba32f) writeonly restrict uniform image2D output_texture;
	
	layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;
	void main() {
		ivec2 id = ivec2(gl_GlobalInvocationID.xy);
		
		vec4 color = imageLoad(input_texture, id);
		vec3 grayscale = vec3((color.r + color.g + color.b) / 3.0);
		
		imageStore(output_texture, id, vec4(grayscale, 1.0));
	}

## Demos

I've made a few sample projects that use this plugin:
- Slime Mold Simulation - https://github.com/DevPoodle/compute-helper-demo
- Boids Simulation - https://github.com/DevPoodle/godot-boids

## Other Information

For more detailed information, like future updates or currently known issues, check the Git page - https://github.com/DevPoodle/compute-shader-plus
