# Autoload para manejar las cartas
extends Node2D

signal move_finished

func move_card_to_position(card: Node2D, target_pos: Vector2, target_time: float, target_rot: float) -> void:
    # Crear un Tween para mover la carta
    var move_tween: Tween = create_tween()

    # Ajustar la rotación de la carta
    card.rotation = deg_to_rad(target_rot)

    # Animar la posición de la carta
    move_tween.tween_property(card, "position", target_pos, target_time)

    # Esperar a que la animación termine
    await move_tween.finished

    # Emitir señal de finalización del movimiento
    emit_signal("move_finished")