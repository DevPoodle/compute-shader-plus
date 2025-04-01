# Tutorial
This simple tutorial will show you how to create a compute shader that makes an image grayscale. First, we need to load a sample image. For now, I'll just create a 256x256 completely red image. If all goes well, this image wil turn into a medium shade of gray after it is put through a compute shader.
```gdscript
var image := Image.create(256, 256, false, Image.FORMAT_RGBAF)
image.fill(Color.RED)
```
This creates the image. Next, we need to load a compute shader. I'll create a new shader called \"compute_shader.glsl\" containing this:
```glsl
#[compute]
#version 450

layout(set = 0, binding = 0, rgba32f) readonly uniform image2D input_texture;
layout(set = 0, binding = 1, rgba32f) writeonly restrict uniform image2D output_texture;

layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;
void main() {
	ivec2 id = ivec2(gl_GlobalInvocationID.xy);
	
	// Sample the color of the input texture
	vec4 color = imageLoad(input_texture, id);
	// Average each color channel
	vec3 grayscale = vec3((color.r + color.g + color.b) / 3.0);
	// Write grayscale to the output texture
	imageStore(output_texture, id, vec4(grayscale, 1.0));
}
```
Let's break this down piece by piece. The first few lines specify that it is a compute shader using version #450 of GLSL. The next two lines beginning with "layout" specify the two uniforms we'll be using throughout the shader. The first is read-only and is the image we'll be taking in. The second is write-only and is the final output of our shader. The next line also begins with "layout", but this one does something different. It tells the shader how many times it should run for each work group. You can think about this as a nested for-loop, where in total it runs x\*y\*z times. For now we have all of them set to one, which is very inefficient, but will make our code later on a little simpler. The main function is where all of the shader's actual code takes place. It is fairly self-explanatory if you're familiar with GLSL. The only thing that might be confusing is the id variable. Going back to thinking of this as a nested for-loop, the id variable is basically the iterator. So, each time the shader runs, it generates a unique ivec2 that we can use to sample our textures.

Next, let's load this shader into our script and set our uniforms:
```gdscript
var compute_shader := ComputeHelper.create("res://compute_shader.glsl")
var input_texture := ImageUniform.create(image)
var output_texture := SharedImageUniform.create(input_texture)
compute_shader.add_uniform_array([input_texture, output_texture])
```
First, we create a new ComputeHelper object that loads our shader. Then, we create two uniform objects for our input and output. You might be wondering why we're using a SharedImageUniform for our output instead of a regular ImageUniform. A SharedImageUniform will automatically update and be updated by its source ImageUniform whenever either goes through a compute shader, meaning you could run the shader multiple times without having to manually update anything. This may be useful if you're trying to run this shader every frame. 

Next, we have to call add_uniform_array on our compute shader to add our uniforms. Something you might have noticed earlier, is that each uniform in our shader had a binding specified. Our input texture had binding=0, and our output texture had binding=1. When you add a uniform to a ComputeHelper object, it automatically assigns each uniform a binding based on the order they were added. The first always has a binding of zero, and each new uniform adds one to its binding.

With this clarified, we now just need to run our shader and get the final output:

```gdscript
var work_groups := Vector3i(256, 256, 1)
compute_shader.run(work_groups)
ComputeHelper.sync()
image = output_texture.get_image()
```

The work groups variable is what we were talking about earlier with how many times the shader is run. We are creating a work group for each pixel in our image, and  remember, that our shader is running once for each work group. We then run our shader using this amount. To get our output, we call ComputeHelper.sync(), to make sure the shader is finished running. Then, we set our image to the data in the output texture.

**Warning:** Getting any sort of data back from the GPU is *very* slow, so I would highly recommend against it for any shader that is running multiple times a second. If you must do so, you can use the corresponding asynchronous get_data functions in each uniform type to make things a little smoother.

Here is our final script:
```gdscript
var image := Image.create(256, 256, false, Image.FORMAT_RGBAF)
image.fill(Color.RED)

var compute_shader := ComputeHelper.create("res://compute-shader.glsl")
var input_texture := ImageUniform.create(image)
var output_texture := SharedImageUniform.create(input_texture)
compute_shader.add_uniform_array([input_texture, output_texture])

var work_groups := Vector3i(256, 256, 1)
compute_shader.run(work_groups)
ComputeHelper.sync()

image = output_texture.get_image()
```

Here is the corresponding compute shader:
```glsl
#[compute]
#version 450

layout(set = 0, binding = 0, rgba32f) readonly uniform image2D input_texture;
layout(set = 0, binding = 1, rgba32f) writeonly restrict uniform image2D output_texture;

layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;
void main() {
	ivec2 id = ivec2(gl_GlobalInvocationID.xy);
	
	// Sample the color of the input texture
	vec4 color = imageLoad(input_texture, id);
	// Average each color channel
	vec3 grayscale = vec3((color.r + color.g + color.b) / 3.0);
	// Write grayscale to the output texture
	imageStore(output_texture, id, vec4(grayscale, 1.0));
}
```