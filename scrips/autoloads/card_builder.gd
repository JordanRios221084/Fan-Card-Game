# --- Autoload para construir cartas ---
extends Node

# --- Mapa de colores para las cartas ---
var color_map: Dictionary = {
	"red": Color(0.996, 0, 0),
	"blue": Color(0.011, 0.352, 0.886),
	"green": Color(0.001, 0.729, 0.011),
	"yellow": Color(1, 0.792, 0.007),
	"black": Color.BLACK
}

# --- Función para construir una carta ---
func build_card(card_values: CardValues, new_card: Card, card_sprite_path: String) -> Card:
	# Asignar valores a la nueva carta
	new_card.card_id = card_values.card_id
	new_card.card_type = card_values.card_type
	new_card.card_color = card_values.card_color
	new_card.card_symbol = card_values.card_symbol
	new_card.card_effect = card_values.card_effect
	new_card.front_sprite.texture = load(card_sprite_path)

	# Asignar el color objetivo basado en el color de la carta
	new_card.target_color = color_map.get(card_values.card_color)
	
	# Configurar el material del sprite frontal con el color objetivo
	var temp_shader_material: ShaderMaterial = new_card.front_sprite.material.duplicate() as ShaderMaterial
	temp_shader_material.set_shader_parameter("target_color", new_card.target_color)
	new_card.front_sprite.material = temp_shader_material
	
	# Devolver la nueva carta
	return new_card
