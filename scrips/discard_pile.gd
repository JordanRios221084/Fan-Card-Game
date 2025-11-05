extends Node2D
class_name DiscardPile

# --- Señales ---
signal card_played(last_card: Card)

# --- Variables ---
var discarded_cards: Array = []
var top_card: Card
var discard_position: Vector2 = self.position

# --- Función para recibir una carta en el montón de descarte ---
func receive_card(new_card: Card, origin: Node2D) -> void:
	# Reparentar la carta al montón de descarte
	new_card.reparent(self)

	# Añadir la carta a la lista de cartas descartadas
	discarded_cards.append(new_card)
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
	await CardManager.move_card_to_position(new_card, discard_position, 0.2, random_rotation)
	
	# Emitir la señal de carta jugada
	emit_signal("card_played")