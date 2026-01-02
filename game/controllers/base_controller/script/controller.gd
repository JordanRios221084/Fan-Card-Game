class_name Controller
extends Node2D
## Clase base para los controladores del juego.

## Verifica si una carta IA es válida para jugar.
@warning_ignore("unused_signal")
signal check_card(card: Card)
## Juega una carta por parte del jugador IA.
@warning_ignore("unused_signal")
signal play_card(card: Card, player: Player)
## Solicita que el jugador IA robe una carta.
@warning_ignore("unused_signal")
signal draw_card(player: Player)

# --- Exports ---
@export_group("References")
## Referencia al [GameManager] para manejar el estado del juego.
@export var game_manager: GameManager

# --- Public Variables ---
## Referencia al jugador actual cuyo turno se está procesando.
## Se debe asignar antes de llamar a try_to_process_turn().
var _player: Player


# --- Public Functions ---
## Asigna un nuevo jugador al controlador.
func set_player(new_player: Player) -> void:
	_player = new_player


## Intenta procesar el turno del jugador actual.
## Si no hay un jugador actual, la función termina sin hacer nada.
func try_to_process_turn() -> void:
	# Si no hay un jugador asignado, terminamos.
	if not _player:
		return
	
	await _process_turn()

# --- Private Functions ---
## Procesa el turno del jugador actual.
func _process_turn() -> void:
	await get_tree().create_timer(0.1).timeout
	pass


## Verifica las cartas actuales en la mano del jugador. [br]
## Si [param already_drawning] es verdadero, espera a que el jugador termine de robar antes de verificar.
func _check_current_cards(already_drawning: bool) -> void:
	print(already_drawning)
	pass