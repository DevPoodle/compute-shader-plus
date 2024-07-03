# Compute Shader Plus

<p align="center">
	<img src="icon.svg" width="256">
</p>

This Godot 4 plugin adds in a ComputeHelper class that keeps track of compute shaders and their uniforms.
Here's a simple example of a shader that reads and then writes to a texture (ideally in the render thread):

```gdscript
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
```
## Demos

I've made a few sample projects that use this plugin:
- [Slime Mold Simulation](https://github.com/DevPoodle/compute-helper-demo)
- [Boids Simulation](https://github.com/DevPoodle/godot-boids)

## Planned Additions

There's a few things I'd like to add to this plugin eventually:

- A new LinkedArrayUniform class. Because arrays are passed by reference, it should be possible to have a class that automatically reads from and updates a given array without the user having to call functions like get_data() or update().
- A more optimized use of uniform sets. From examples I've seen, I know there are times where uniforms and uniform sets can be reused, but I haven't done enough testing to know exactly when, or how I'd want to implement that in this plugin.

## Other Resources

For more information on compute shaders in Godot 4, here are some useful resources:

- [Official Compute Texture Demo Project](https://github.com/godotengine/godot-demo-projects/tree/master/compute/texture)
- ["Godot 4 - Conway's Game Of Life (Full Lesson)" Video Tutorial (Uses C#)](https://www.youtube.com/watch?v=VQhi2w1E0iU)
- ["Everything About Textures in Compute Shaders!" Article](https://nekotoarts.github.io/teaching/compute-shader-textures)
- ["How to use Compute Shaders in Godot 4" Video](https://www.youtube.com/watch?v=5CKvGYqagyI)

And while you're here, here's some similar plugins you might want to look at:

- [Godot-GPU-Computer](https://github.com/PGComai/Godot-GPU-Computer)
- [Compute Shader Studio](https://github.com/pascal-ballet/ComputeShaderStudio)
