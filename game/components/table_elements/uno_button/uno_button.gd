class_name UnoButton
extends Button
## Componente que representa el botón "UNO" en el juego.

var human_player: Player = null

func show_button(state: bool) -> void:
	self.visible = state

## --- Signals Callbacks ---
func _on_pressed() -> void:
	UnoManager.yell_uno(human_player)
	show_button(false)
