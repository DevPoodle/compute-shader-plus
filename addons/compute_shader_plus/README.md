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

## Demos

I've made a few sample projects that use this plugin:
- Slime Mold Simulation - https://github.com/DevPoodle/compute-helper-demo
- Boids Simulation - https://github.com/DevPoodle/godot-boids

## Other Information

For more detailed information, like future updates or currently known issues, check the Git page - https://github.com/DevPoodle/compute-shader-plus