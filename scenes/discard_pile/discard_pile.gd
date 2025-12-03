class_name DiscardPile
extends Node2D
## Se encarga de gestionar el montón de descarte en el juego de cartas.
##
## Permite recibir cartas descartadas, actualizar la carta superior y reproducir 
## animaciones relacionadas con el descarte de cartas.

# --- Public Variables ---
## Carta superior del montón de descarte. Dicta el símbolo y color actual.
## Puede ser null al inicio hasta que se descarte la primera carta.
var top_card: Card

# --- Private Variables ---
## Cartas que han sido descartadas en el montón.
var _discarded_cards: Array[Card] = []
## Posición local donde caerán las cartas.
## Al ser hijas de este nodo, (0,0) es el centro del montón.
var _discard_position: Vector2 = Vector2.ZERO


# --- Public Functions ---
## Recibe una carta descartada y la añade al montón de descarte.
## La función reubica la carta, actualiza la carta superior y anima el movimiento. [br]
##
## - [param new_card]: La carta que se va a descartar. [br]
## - [param origin]: El nodo desde el cual se descarta la carta (Deck o Player).
func receive_card(new_card: Card, origin: Node) -> void:
	# Reparentar la carta al montón de descarte
	new_card.reparent(self)

	# Añadir la carta a la lista de cartas descartadas y actualizar referencia
	_discarded_cards.append(new_card)
	new_card.current_parent = self

	# Actualizar la carta superior (vital para las reglas del juego)
	top_card = new_card

	# Gestión de animaciones según el origen:
	# Si viene del Mazo (inicio del juego), hay que voltearla.
	if origin is Deck:
		new_card.card_animator.play("flip_card")
	# Si viene de la IA (que suele tener cartas ocultas), hay que voltearla.
	elif origin is Player and not (origin as Player).is_human:
		new_card.card_animator.play("flip_card")

	# Generar una rotación aleatoria para dar efecto de "desorden" natural (Grados).
	var random_rotation: float = randf_range(-180.0, 180.0)

	# Mover la carta a la posición central del descarte usando el Manager
	await CardManager.move_card_to_position(new_card, _discard_position, 0.2, random_rotation)
