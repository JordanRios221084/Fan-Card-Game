extends Node
## Construye cartas con atributos específicos y asigna colores y sprites.

# --- Constants ---
## Estructura de datos para los colores de la carta.
## Los colores disponibles son: "red", "blue", "green", "yellow", "black".
const _COLOR_MAP: Dictionary = {
	"red": Color(0.996, 0, 0),
	"blue": Color(0.011, 0.352, 0.886),
	"green": Color(0.001, 0.729, 0.011),
	"yellow": Color(1, 0.792, 0.007),
	"black": Color.BLACK
}


# --- Public Functions ---
## Método para construir una carta con valores específicos.
## Configura propiedades, textura y el shader del color.
## Devuelve la carta configurada.
func build_card(card_values: CardValues, new_card: Card, card_sprite_path: String) -> Card:
	# Asignar valores a la nueva carta
	new_card.card_id = card_values.card_id
	new_card.card_type = card_values.card_type
	new_card.card_color = card_values.card_color
	new_card.card_symbol = card_values.card_symbol
	new_card.card_effect = card_values.card_effect
	
	# Cargar y asignar la textura
	# Nota: load() es sincrónico. Si hay muchas cartas, considera pre-cargar las texturas.
	new_card.front_sprite.texture = load(card_sprite_path)

	# Asignar el color objetivo basado en el color de la carta.
	# Usamos el diccionario constante _COLOR_MAP. Si el color no existe, devuelve blanco por defecto.
	new_card.target_color = _COLOR_MAP.get(card_values.card_color, Color.WHITE)
	
	# Configurar el material del sprite frontal con el color objetivo
	# Es vital duplicar el material para que el cambio de color solo afecte a ESTA carta.
	if new_card.front_sprite.material:
		var temp_shader_material: ShaderMaterial = new_card.front_sprite.material.duplicate() as ShaderMaterial
		temp_shader_material.set_shader_parameter("target_color", new_card.target_color)
		new_card.front_sprite.material = temp_shader_material
	
	# Devolver la nueva carta
	return new_card
