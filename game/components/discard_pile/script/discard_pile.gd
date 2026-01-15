class_name DiscardPile
extends Node2D
## Se encarga de gestionar el montón de descarte en el juego de cartas.
##
## Permite recibir cartas descartadas, actualizar la carta superior y reproducir 
## animaciones relacionadas con el descarte de cartas.

# --- Signals ---
signal first_card_discarded(card: Card) ## Se emite cuando la primera carta es descartada del montón.

# --- Constants ---
## Límites de desplazamiento en grados.
const OFFSET_LIMIT: Vector2 = Vector2(-10.0, 10.0)
## Límites de rotación en grados.
const ROTATION_LIMIT: Vector2 = Vector2(-180.0, 180.0)
## Tiempo de animación para mover cartas al montón de descarte.
const  MOVE_TIME_SECONDS: float = 0.4

# --- Variables ---
var top_card: Card ## Carta superior del montón de descarte. Dicta el símbolo y color actual.
var discarded_cards: Array[Card] = [] ## Cartas que han sido descartadas en el montón.
var discard_position: Vector2 ## Posición local donde caerán las cartas.


# --- Public Functions ---
## Recibe una carta descartada y la añade al montón de descarte.
## La función reubica la carta, actualiza la carta superior y anima el movimiento. [br]
##
## - [param new_card]: La carta que se va a descartar. [br]
## - [param origin]: El nodo desde el cual se descarta la carta (Deck o Player).
func receive_card(new_card: Card, origin: Node) -> void:
	if origin is Deck:
		new_card.card_animator.play("flip_card")
	
	if origin is Player and not (origin as Player).is_human:
		new_card.card_animator.play("flip_card")

	if discarded_cards.size() > 5:
		first_card_discarded.emit(discarded_cards[0])
		discarded_cards.pop_front()
	
	new_card.reparent(self)
	discarded_cards.append(new_card)
	
	new_card.current_parent = self
	top_card = new_card

	# Generar valores aleatorios para rotación y posición
	var random_rotation: float = randf_range(ROTATION_LIMIT.x, ROTATION_LIMIT.y)
	var random_x_offset: float = randf_range(OFFSET_LIMIT.x, OFFSET_LIMIT.y)
	var random_y_offset: float = randf_range(OFFSET_LIMIT.x, OFFSET_LIMIT.y)
	var random_offset: Vector2 = Vector2(random_x_offset, random_y_offset)
	
	discard_position = Vector2.ZERO
	discard_position += random_offset

	CardManager.set_card_opacity(new_card, true)
	await CardManager.move_card_to_position(new_card, discard_position, MOVE_TIME_SECONDS, random_rotation)


func check_top_card_effect_used() -> bool:
	return top_card.is_effect_used