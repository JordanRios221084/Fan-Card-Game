class_name UnoButton
extends Button
## Componente que representa el botón "UNO" en el juego.


# --- Signals ---
## Emite la señal ¡UNO! cuando el botón es presionado.
signal uno_called


## --- Signals Callbacks ---
func _on_pressed() -> void:
	uno_called.emit()
	
	disabled = true
	visible = false