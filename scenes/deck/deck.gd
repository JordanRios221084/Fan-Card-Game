class_name Deck
extends Node2D
## Mazo del juego.
##
## Se encarga de manejar las cartas que los jugadores roban en la partida.
## Cada vez que un jugador roba una carta, el mazo se vuelve a barajar.
## La carta robada es creada al momento en el autoload [CardBuilder].

# --- Private Constants ---
## Escena precargada de la carta para instanciar nuevas cartas cuando se roba del mazo.
const _CARD_SCENE: PackedScene = preload("res://scenes/card/card.tscn")
## Estructura de datos para los colores de la carta.
## Los colores disponibles son: "red", "blue", "green", "yellow", "black".
const _COLOR_MAP: Dictionary = {
	"red": Color(0.996, 0, 0),
	"blue": Color(0.011, 0.352, 0.886),
	"green": Color(0.001, 0.729, 0.011),
	"yellow": Color(1, 0.792, 0.007),
	"black": Color.BLACK
}

# --- Exports ---
@export_group("References")
## Referencia al [Sprite2D] que contiene la textura del mazo.
@export var deck_sprite: Sprite2D
## Referencia al [CollisionShape2D] que se encarga de las colisiones del mazo.
@export var deck_collision_shape: CollisionShape2D

# --- Public Variables ---
## Almacena las cartas que el mazo puede devolver llamando a su función [method Deck.draw_card].
var current_deck: Array[Dictionary] = []


# --- Public Functions ---
## Roba una carta del mazo, mezcla la baraja, comprueba si está vacía y crea una nueva carta si es posible.
## Devuelve la carta robada o devuelve [param null] si la baraja está vacía.
func draw_card() -> Card:
	if current_deck.is_empty():
		push_warning("Deck: La baraja está vacía. No se puede robar una carta.")
		return null
	
	current_deck.shuffle()
	
	var card_drawn_data: Dictionary = current_deck.pop_back()
	var card_sprite_path: String = "res://assets/sprites/cards/" + card_drawn_data["Type"] + ".png" 
	var new_card: Card = _build_card(card_drawn_data, card_sprite_path)

	add_child(new_card)

	return new_card

## Recupera una carta descartada y la añade de nuevo a la baraja del mazo.
## La carta es liberada del árbol de escena después de recuperar sus valores. [br]
## - [param recovered_card]: La carta que se va a recuperar.
func recover_card(recovered_card: Card) -> void:
	var recovered_card_data: Dictionary = {}

	recovered_card_data = recovered_card.values

	current_deck.append(recovered_card_data)
	CardManager.card_scale_down(recovered_card)


# --- Private Functions ---
## Crea una nueva carta, configura propiedades, textura y el shader del color.
## Devuelve la carta configurada.
func _build_card(card_values: Dictionary, card_sprite_path: String) -> Card:
	var card: Card = _CARD_SCENE.instantiate() as Card

	card.values = card_values
	card.front_sprite.texture = load(card_sprite_path)
	card.values["TargetColor"] = _COLOR_MAP[card.values["Color"]]

	if card.front_sprite.material:
		# Duplicar el material para evitar modificar el original
		var temp_shader_material: ShaderMaterial = card.front_sprite.material.duplicate() as ShaderMaterial
		temp_shader_material.set_shader_parameter("target_color", card.values["TargetColor"])
		card.front_sprite.material = temp_shader_material
	
	return card