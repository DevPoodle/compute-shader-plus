# Compute Helper

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

## Planned Additions

There's quite a few things that still need to be added or cleaned up before this plugin can be considered "complete":

- [X] In SharedImageUniform, the source ImageUniform should be tracked so that it can automatically update itself if the original ImageUniform's texture buffer is changed. This should prevent some unnecessary calls of update_uniform.
- [ ] The ImageFormatHelper's method, convert_image_format_to_data_format, should be expanded upon to include an exhaustive list of all possible image formats.
- [ ] A new set of LinkedUniform classes should be added. These would automatically update their data whenever their source is updated, and update their source when their data is updated. For example, a LinkedImageUniform would read from an image before going through a compute shader, and then update that same image automatically when the compute shader is done.
- [ ] Support for sampler uniforms should be added.

## Other Resources

For more information on compute shaders in Godot 4, here are some useful resources:

- [Official Compute Texture Demo Project](https://github.com/godotengine/godot-demo-projects/tree/master/compute/texture)
- ["Godot 4 - Conway's Game Of Life (Full Lesson)" Video Tutorial (Uses C#)](https://www.youtube.com/watch?v=VQhi2w1E0iU)
- ["Everything About Textures in Compute Shaders!" Article](https://nekotoarts.github.io/teaching/compute-shader-textures)
- ["How to use Compute Shaders in Godot 4" Video](https://www.youtube.com/watch?v=5CKvGYqagyI)

And while you're here, here's some similar plugins you might want to look at:

- [Godot-GPU-Computer](https://github.com/PGComai/Godot-GPU-Computer)
- [Compute Shader Studio](https://github.com/pascal-ballet/ComputeShaderStudio)
