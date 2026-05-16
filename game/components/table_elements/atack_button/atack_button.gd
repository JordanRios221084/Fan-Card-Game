extends Button
class_name AtackButton
## Componente que representa el botón "!!!" en el juego.

var human_player: Player = null

func _ready() -> void:
	UnoManager.connect("vulnerability_state_changed", _on_uno_managervulnerability_state_changed)

func show_button(state: bool) -> void:
	self.visible = state

## --- Signals Callbacks ---
func _on_pressed() -> void:
	UnoManager.challenge_uno(human_player)
	show_button(false)

func _on_uno_managervulnerability_state_changed(active: bool) -> void:
	if UnoManager.vulnerable_player != human_player:
		show_button(active)
