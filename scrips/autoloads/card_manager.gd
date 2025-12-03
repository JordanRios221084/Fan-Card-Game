extends Node
## Autoload para manejar las cartas.
##
## Gestiona el movimiento y las animaciones de las cartas utilizando Tweens.
## Debe estar configurado como Singleton en los ajustes del proyecto.

# --- Signals ---
## Señal emitida cuando una carta termina de moverse.
signal move_finished


# --- Public Functions ---
## Mueve una carta a una posición y rotación objetivo en un tiempo determinado.
## Utiliza un Tween paralelo para animar posición y rotación simultáneamente.
##
## - [param card]: La carta (Node2D) a mover.
## - [param target_pos]: La posición objetivo (Vector2).
## - [param target_time_seconds]: Duración de la animación en segundos.
## - [param target_rot_degrees]: Rotación objetivo en grados.
func move_card_to_position(card: Node2D, target_pos: Vector2, target_time_seconds: float, target_rot_degrees: float) -> void:
	# Crear un Tween y configurarlo para que ejecute animaciones en paralelo
	var move_tween: Tween = create_tween().set_parallel(true)
	
	# Configurar el tipo de transición para que el movimiento sea suave ("Physics-like")
	move_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	# Animar la rotación (convirtiendo grados a radianes)
	move_tween.tween_property(card, "rotation", deg_to_rad(target_rot_degrees), target_time_seconds)
	# Animar la posición de la carta
	move_tween.tween_property(card, "position", target_pos, target_time_seconds)

	# Esperar a que la animación termine (el tween se destruye automáticamente al terminar)
	await move_tween.finished

	# Emitir señal de finalización usando la sintaxis de Godot 4
	move_finished.emit()


func set_card_opacity(card: Card, enabled: bool) -> void:
	var alpha_value: float = 0.0 if enabled else 0.25
	
	# Asumiendo que opacity_sprite es blanco y controlamos alpha con modulate
	card.opacity_sprite.modulate = Color(0, 0, 0, alpha_value)