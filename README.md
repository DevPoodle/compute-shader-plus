# Compute Shader Plus

<p align="center">
	<img src="icon.svg" width="256">
</p>

This Godot 4 plugin adds in a ComputeHelper class that keeps track of compute shaders and their uniforms.

Here's a simple example of a shader that reads and then writes to a texture, making it grayscale (ideally in the render thread). You can find a more thorough explanation in [`docs/tutorial.md`](docs/tutorial.md):

```gdscript
var image := Image.create(image_size.x, image_size.y, false, Image.FORMAT_RGBAF)
image.fill(Color.RED)

var compute_shader := ComputeHelper.create("res://compute-shader.glsl")
var input_texture := ImageUniform.create(image)
var output_texture := SharedImageUniform.create(input_texture)
compute_shader.add_uniform_array([input_texture, output_texture])

var work_groups := Vector3i(image_size.x, image_size.y, 1)
compute_shader.run(work_groups)
ComputeHelper.sync()

image = output_texture.get_image()
```
Corresponding shader file:
```glsl
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
```
## Demos

I've made a few sample projects that use this plugin:
- [Slime Mold Simulation](https://github.com/DevPoodle/compute-helper-demo)
- [Boids Simulation](https://github.com/DevPoodle/godot-boids)

## Planned Additions

There's a few things I'd like to add to this plugin eventually:

- Basic shader reflection features, such as the ability to get the names of all of the uniforms in a shader, and the ability to set a shader's uniform based off of its name.
- More thorough documentation. Currently, there is only a basic tutorial, but I'd like to add some other examples, such as using the plugin in a compositor effect, and using it with other RenderingDevice functions.

## Other Resources

For more information on compute shaders in Godot 4, here are some useful resources:

- [Official Compute Texture Demo Project](https://github.com/godotengine/godot-demo-projects/tree/master/compute/texture)
- ["Godot 4 - Conway's Game Of Life (Full Lesson)" Video Tutorial (Uses C#)](https://www.youtube.com/watch?v=VQhi2w1E0iU)
- ["Everything About Textures in Compute Shaders!" Article](https://nekotoarts.github.io/teaching/compute-shader-textures)
- ["How to use Compute Shaders in Godot 4" Video](https://www.youtube.com/watch?v=5CKvGYqagyI)

And while you're here, here's some similar plugins you might want to look at:

- [Godot-GPU-Computer](https://github.com/PGComai/Godot-GPU-Computer)
- [Compute Shader Studio](https://github.com/pascal-ballet/ComputeShaderStudio)
- [Acerola-Compute](https://github.com/GarrettGunnell/Acerola-Compute)
