Toon Shader by Chris Cloutier

Takes three textures, the first being the texture in light, the second being the texture when unlit, and the third being a normal map. The shader takes the incoming light and  determines whether to use the lit or unlit texture depending on brightness and angle of the light. In addition, it adds specular highlights and rim lighting, in addition to creating an outline by expanding the vertices outward in their normal direction in a first pass, with the front culled.

Different lit and unlit textures are used as a simplified method of having light interact with different parts of the texture differently. This allows, for example, areas to simulate giving off light by being the same in both textures. 

Various other options are included, which are hopefully self explanatory, but for the sake of clarity, I'll go over them anyway
-Use Normal turns the normal map on or off
-Lit threshold adjusts the value that determines if a fragment is lit. Putting it to 0 uses only lit, putting it to max uses only unlit
-Outline thickness adjusts how thick the outline is
-Outline Color determines the color of the outline, but only if solid outline is checked
-Solid outline: when checked, uses a single outline color, determined by outline color. Otherwise uses the same color as the space it outlines, dimmed by Outline Brightness
-Rim Light Color/Rim Light Power determine how bright and what color the rim light uses
-Specularity determines the level of specularity of the material. Lower numbers look more shiny
-Specular Brightness determines how much brighter the specular highlights are relative to the lit texture. Minimum is the same color, maximum is pure white

For ease of messing with various possible options on the whole model at once, since it uses several materials, I've also included a Shader Options script that allows the shader values to be modified for all of the materials simultaneously.

