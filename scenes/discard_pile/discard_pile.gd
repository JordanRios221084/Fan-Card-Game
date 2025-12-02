extends Node2D
class_name DiscardPile
## [b]Descripción:[/b] Nodo DiscardPile que se encarga de las cartas descartadas. [br]
## Contiene las variables para el menejo de las cartas descartadas y su posición,
## así como la carta superior que dicta el simbolo y color
## con el que se juega.

# --- Variables ---
var top_card: Card ## La carta superior del montón de descarte que dicta el símbolo y color actual.
var _discarded_cards: Array = [] ## Lista de cartas que han sido descartadas en el montón.
var _discard_position: Vector2 = self.position ## Posición donde se colocan las cartas descartadas.

## Pertenece a: [DiscardPile] [br]
## [b]Descripción:[/b] Recibe una carta descartada y la añade al montón de descarte. [br]
## La función reubica la carta en el montón de descarte, actualiza la carta superior
## y reproduce animaciones si es necesario.	[br]
## Parámetros: [br]
## [param new_card] (Card) - La carta que se va a descartar. [br]
## [param origin] (Node2D) - El nodo desde el cual se descarta la carta (puede ser un mazo o un jugador).
func receive_card(new_card: Card, origin: Node2D) -> void:
	# Reparentar la carta al montón de descarte
	new_card.reparent(self)

	# Añadir la carta a la lista de cartas descartadas
	_discarded_cards.append(new_card)
	new_card.current_parent = self

	# Actualizar la carta superior
	top_card = new_card

	# Si la carta proviene del mazo, reproducir la animación de voltear la carta
	if origin is Deck:
		new_card.card_animator.play("flip_card")
	
	# Si la carta proviene de un jugador que no es humano, reproducir la animación de voltear la carta
	if origin is Player and not (origin as Player).is_human:
		new_card.card_animator.play("flip_card")

	# Generar una rotación aleatoria para la carta
	var random_rotation: float = rad_to_deg(randf_range(-180, 180))

	# Mover la carta a la posición de descarte
	await CardManager.move_card_to_position(new_card, _discard_position, 0.2, random_rotation)
