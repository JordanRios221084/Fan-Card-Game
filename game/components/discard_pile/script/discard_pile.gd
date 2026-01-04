class_name DiscardPile
extends Node2D
## Se encarga de gestionar el montón de descarte en el juego de cartas.
##
## Permite recibir cartas descartadas, actualizar la carta superior y reproducir 
## animaciones relacionadas con el descarte de cartas.

# --- Signals ---
signal first_card_discarded(card: Card) ## Se emite cuando la primera carta es descartada del montón.

# --- Private Constants ---
## Límites de desplazamiento en grados.
const _OFFSET_LIMIT: Vector2 = Vector2(-10.0, 10.0)
## Límites de rotación en grados.
const _ROTATION_LIMIT: Vector2 = Vector2(-180.0, 180.0)
## Tiempo de animación para mover cartas al montón de descarte.
const  _MOVE_TIME_SECONDS: float = 0.4

# --- Public Variables ---
## Carta superior del montón de descarte. Dicta el símbolo y color actual.
## Puede ser null al inicio hasta que se descarte la primera carta.
var top_card: Card

# --- Private Variables ---
## Cartas que han sido descartadas en el montón.
var _discarded_cards: Array[Card] = []
## Posición local donde caerán las cartas.
var _discard_position: Vector2


# --- Public Functions ---
## Recibe una carta descartada y la añade al montón de descarte.
## La función reubica la carta, actualiza la carta superior y anima el movimiento. [br]
##
## - [param new_card]: La carta que se va a descartar. [br]
## - [param origin]: El nodo desde el cual se descarta la carta (Deck o Player).
func receive_card(new_card: Card, origin: Node) -> void:
	new_card.reparent(self)

	_discarded_cards.append(new_card)
	new_card.current_parent = self

	top_card = new_card

	if origin is Deck:
		new_card.card_animator.play("flip_card")
	
	if origin is Player and not (origin as Player).is_human:
		new_card.card_animator.play("flip_card")

	if _discarded_cards.size() > 5:
		first_card_discarded.emit(_discarded_cards[0])
		_discarded_cards.pop_front()

	# Generar valores aleatorios para rotación y posición
	var random_rotation: float = randf_range(_ROTATION_LIMIT.x, _ROTATION_LIMIT.y)
	var random_x_offset: float = randf_range(_OFFSET_LIMIT.x, _OFFSET_LIMIT.y)
	var random_y_offset: float = randf_range(_OFFSET_LIMIT.x, _OFFSET_LIMIT.y)
	var random_offset: Vector2 = Vector2(random_x_offset, random_y_offset)
	
	_discard_position = Vector2.ZERO
	_discard_position += random_offset

	print("Tiempo N°3 de espera: ", _MOVE_TIME_SECONDS)
	CardManager.set_card_opacity(new_card, true)
	new_card.collision_shape.disabled = true
	await CardManager.move_card_to_position(new_card, _discard_position, _MOVE_TIME_SECONDS, random_rotation)