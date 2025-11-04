// color_swap.gdshader
shader_type canvas_item;

// Esta es la variable que controlarás desde GDScript.
// : source_color nos da un selector de color en el editor.
uniform vec4 target_color : source_color;

// El color gris que buscamos (127 / 255 = 0.498)
const vec3 SOURCE_GRAY = vec3(0.498, 0.498, 0.498);

// Un pequeño umbral para manejar imprecisiones de compresión (0.01 es seguro)
const float THRESHOLD = 0.01;

void fragment() {
	// 1. Obtener el color original de la textura
	vec4 current_color = texture(TEXTURE, UV);
	
	// 2. Comprobar si el color del píxel está "cerca" de nuestro gris
	if (distance(current_color.rgb, SOURCE_GRAY) < THRESHOLD) {
		// 3. ¡Es gris! Reemplazarlo por el target_color.
		// Usamos el RGB del target_color, pero mantenemos el Alpha (transparencia)
		// del píxel original. Esto preserva los bordes suaves de tu carta.
		COLOR = vec4(target_color.rgb, current_color.a);
	} else {
		// 4. No es gris. Dejar el píxel como estaba.
		COLOR = current_color;
	}
}