class_name DiscardPile
extends Node2D
## Se encarga de gestionar el montón de descarte en el juego de cartas.
##
## Permite recibir cartas descartadas, actualizar la carta superior y reproducir 
## animaciones relacionadas con el descarte de cartas.

# --- Signals ---
signal first_card_discarded(card: Card)

# --- Public Variables ---
## Carta superior del montón de descarte. Dicta el símbolo y color actual.
## Puede ser null al inicio hasta que se descarte la primera carta.
var top_card: Card

# --- Private Variables ---
## Cartas que han sido descartadas en el montón.
var _discarded_cards: Array[Card] = []
## Posición local donde caerán las cartas.
var _discard_position: Vector2
## Límites para generar offsets aleatorios al descartar cartas.
var _negative_offset_limit: float = -15.0
var _positive_offset_limit: float = 15.0
## Límites para generar rotaciones aleatorias al descartar cartas (en grados).
var _negative_rotation_limit: float = -180.0
var _positive_rotation_limit: float = 180.0


# --- Public Functions ---
## Recibe una carta descartada y la añade al montón de descarte.
## La función reubica la carta, actualiza la carta superior y anima el movimiento. [br]
##
## - [param new_card]: La carta que se va a descartar. [br]
## - [param origin]: El nodo desde el cual se descarta la carta (Deck o Player).
func receive_card(new_card: Card, origin: Node) -> void:
	# Limitar el tamaño del montón de descarte a 4 cartas visibles
	if _discarded_cards.size() > 4:
		# Emitir señal si es la primera carta descartada
		first_card_discarded.emit(_discarded_cards[0])
		_discarded_cards.pop_front()
	
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
	var random_rotation: float = randf_range(_negative_rotation_limit, _positive_rotation_limit)

	# Generar un pequeño offset aleatorio en X e Y para evitar que las cartas queden perfectamente alineadas.
	var ramdon_offset: Vector2 = Vector2(randf_range(_negative_offset_limit, _positive_offset_limit), 
			randf_range(_negative_offset_limit, _positive_offset_limit))
	
	# Calcular la posición final de descarte, empezando desde el centro (0,0)
	_discard_position = Vector2.ZERO
	# Aplicar el offset generado
	_discard_position += ramdon_offset

	# Mover la carta a la posición central del descarte usando el Manager
	await CardManager.move_card_to_position(new_card, _discard_position, 0.2, random_rotation)
