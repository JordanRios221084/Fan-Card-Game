class_name Deck
extends Node2D
## Mazo del juego.
##
## Se encarga de manejar las cartas que los jugadores roban en la partida.
## Cada vez que un jugador roba una carta, el mazo se vuelve a barajar.
## La carta robada es creada al momento en el autoload [CardBuilder].

# --- Constants ---
## Escena precargada de la carta para instanciar nuevas cartas cuando se roba del mazo.
const _CARD_SCENE: PackedScene = preload("res://scenes/card/card.tscn")

# --- Exports ---
@export_group("References")
## Referencia al [Sprite2D] que contiene la textura del mazo.
@export var deck_sprite: Sprite2D
## Referencia al [CollisionShape2D] que se encarga de las colisiones del mazo.
@export var deck_collision_shape: CollisionShape2D

# --- Public Variables ---
## Almacena las cartas que el mazo puede devolver llamando a su función [method Deck.draw_card].
var current_deck: Array[CardValues] = []


# --- Public Functions ---
## Roba una carta del mazo, mezcla la baraja, comprueba si está vacía y crea una nueva carta si es posible.
## Devuelve la carta robada o devuelve [color=orange]null[/color] si la baraja está vacía.
func draw_card() -> Card:
	# Mezclar la baraja antes de robar una carta (según tu lógica solicitada)
	current_deck.shuffle()

	# Comprobar si la baraja está vacía
	if current_deck.is_empty():
		push_warning("Deck: La baraja está vacía. No se puede robar una carta.")
		return null
	
	# Obtener los valores de la carta robada
	var card_drawn_values: CardValues = current_deck.pop_back()
	
	# Construcción de ruta más segura usando formato de string
	var card_sprite_path: String = "res://assets/sprites/" + card_drawn_values.card_type + ".png" 

	# Instanciar una nueva carta con cast seguro
	var new_card: Card = _CARD_SCENE.instantiate() as Card

	# Añadir la carta al nodo Deck para que entre en el árbol de escena
	add_child(new_card)

	# Configurar las propiedades de la carta usando el Autoload
	CardBuilder.build_card(card_drawn_values, new_card, card_sprite_path)

	# Devolver la nueva carta
	return new_card

## Recupera una carta descartada y la añade de nuevo a la baraja del mazo.
## La carta es liberada del árbol de escena después de recuperar sus valores. [br]
## - [param recovered_card]: La carta que se va a recuperar.
func recover_card(recovered_card: Card) -> void:
	# Crear una nueva instancia de CardValues para almacenar los valores de la carta recuperada
	var recovered_card_values: CardValues = CardValues.new()

	# Asignar los valores de la carta recuperada a la nueva instancia
	recovered_card_values.card_id = recovered_card.card_id
	recovered_card_values.card_type = recovered_card.card_type
	recovered_card_values.card_color = recovered_card.card_color
	recovered_card_values.card_symbol = recovered_card.card_symbol
	recovered_card_values.card_effect = recovered_card.card_effect

	# Añadir los valores de la carta recuperada de nuevo a la baraja
	current_deck.append(recovered_card_values)

	# Animar la desaparición de la carta recuperada
	CardManager.card_scale_down(recovered_card)