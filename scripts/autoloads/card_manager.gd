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
## Utiliza un Tween paralelo para animar posición y rotación simultáneamente. [br]
##
## - [param card]: La carta (Node2D) a mover. [br]
## - [param target_pos]: La posición objetivo (Vector2). [br]
## - [param target_time_seconds]: Duración de la animación en segundos. [br]
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


## Configura la opacidad de una carta para indicar si está activa o no. [br]
## - [param card]: La carta cuya opacidad se va a configurar. [br]
## - [param enabled]: Si es true, la carta es completamente visible; si es false
##   la carta es semi-transparente.
func set_card_opacity(card: Card, enabled: bool) -> void:
	var alpha_value: float = 0.0 if enabled else 0.25
	
	# Asumiendo que opacity_sprite es blanco y controlamos alpha con modulate
	card.opacity_sprite.modulate = Color(0, 0, 0, alpha_value)


## ## Desvanece y elimina una carta del juego mediante una animación de escala hacia abajo. [br]
## - [param card]: La carta a desvanecer y eliminar.
func card_scale_down(card: Card) -> void:
	# Crear un Tween para la animación de desvanecimiento
	var fade_tween: Tween = create_tween()
	var tween_duration: float = 1.5
	
	# Configurar el tipo de transición para que el desvanecimiento sea suave
	fade_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	# Animar la opacidad de los sprites de la carta
	fade_tween.tween_property(card, "scale", Vector2.ZERO, tween_duration)

	# Esperar a que la animación termine antes de eliminar la carta
	await fade_tween.finished
	card.queue_free()