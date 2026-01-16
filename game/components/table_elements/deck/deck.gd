class_name Deck
extends Node2D
## Mazo del juego.
##
## Se encarga de manejar las cartas que los jugadores roban en la partida.
## Cada vez que un jugador roba una carta, el mazo se vuelve a barajar.
## La carta robada es creada al momento en el autoload [CardBuilder].


# --- Constants ---
## Escena precargada de la carta para instanciar nuevas cartas cuando se roba del mazo.
const CARD_SCENE: PackedScene = preload("res://game/components/table_elements/card/card.tscn")


# --- Export Variables ---
@export_group("References")
## Referencia al [Sprite2D] que contiene la textura del mazo.
@export var deck_sprite: Sprite2D
## Referencia al [CollisionShape2D] que se encarga de las colisiones del mazo.
@export var deck_collision_shape: CollisionShape2D

# --- Variables ---
## Almacena las cartas que el mazo puede devolver llamando a su función [method Deck.draw_card].
var current_deck: Array[CardValues] = []


# --- Public Functions ---
## Roba una carta del mazo, mezcla la baraja, comprueba si está vacía y crea una nueva carta si es posible.
## Devuelve la carta robada o devuelve [param null] si la baraja está vacía.
func draw_card() -> Card:
	if current_deck.is_empty():
		push_warning("Deck: La baraja está vacía. No se puede robar una carta.")
		return null
	
	current_deck.shuffle()
	
	var card_drawn_data: CardValues = current_deck.pop_back()
	var card_sprite_path: String = "res://assets/sprites/cards/" + card_drawn_data.type + ".png" 
	var new_card: Card = _build_card(card_drawn_data, card_sprite_path)

	add_child(new_card)
	CardManager.set_card_opacity(new_card, false)

	return new_card


## Recupera una carta descartada y la añade de nuevo a la baraja del mazo.
## La carta es liberada del árbol de escena después de recuperar sus valores. [br]
## - [param recovered_card]: La carta que se va a recuperar.
func recover_card(recovered_card: Card) -> void:
	var recovered_card_data: CardValues = CardValues.new()

	recovered_card_data = recovered_card.values

	current_deck.append(recovered_card_data)
	CardManager.card_scale_down(recovered_card)


# --- Private Functions ---
## Crea una nueva carta, configura propiedades, textura y el shader del color.
## Devuelve la carta configurada.
func _build_card(card_values: CardValues, card_sprite_path: String) -> Card:
	var card: Card = CARD_SCENE.instantiate() as Card

	card.values = card_values
	card.front_sprite.texture = load(card_sprite_path)
	card.set_card_color(card_values.color)
	
	return card


func disable_deck() -> void:
	deck_collision_shape.disabled = true


func enable_deck() -> void:
	deck_collision_shape.disabled = false