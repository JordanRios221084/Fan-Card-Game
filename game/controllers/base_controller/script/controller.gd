class_name Controller
extends Node2D
## Clase base para los controladores del juego.


# --- Signals ---
signal play_card(card: Card, player: Player) ## Juega una carta por parte del jugador IA.
signal check_card(card: Card) ## Verifica si una carta IA es válida para jugar.
signal draw_card(player: Player) ## Solicita que el jugador IA robe una carta.
signal draw_finished() ## Señal que indica que el robo de carta ha finalizado.
signal color_selected(color: String)
signal challenge_choice(choice: bool)

# --- Exported Variables ---
@export_group("References")
@export var game_manager: GameManager ## Referencia al [GameManager] para manejar el estado del juego.
@export var player: Player ## Referencia al jugador asociado a este controlador.

const COLOR_MAP: Array[String] = ["red", "green", "blue", "yellow", "black"]

# --- Engine Functions ---
func _ready() -> void:
	player = get_parent() as Player





# ---------------------- Control de Turnos --------------------

## Intenta procesar el turno del jugador actual.
func try_to_process_turn() -> void:
	print("Base Controller: try_to_process_turn called.")

func try_to_select_color() -> void:
	print("Base Controller: try_to_select_color called.")

func try_to_challenge_choice() -> void:
	print("Base Controller: try_to_challenge_choice called.")




# -------------------- Funciones de emisión de señales --------------------

## Emite la señal para jugar una carta por parte del jugador.
func card_play(card_to_play: Card) -> void:
	play_card.emit(card_to_play, player)


## Emite la señal para verificar si una carta es válida para jugar.
func card_check(card_to_check: Card) -> void:
	check_card.emit(card_to_check)


## Emite la señal para que el jugador robe una carta.
func card_draw() -> void:
	draw_card.emit(player)
	await draw_finished


func color_select(color: String) -> void:
	color_selected.emit(color)


func challenge_draw_choice(choice: bool) -> void:
	challenge_choice.emit(choice)


## Emite la señal para notificar que el robo de carta ha finalizado.
func notify_draw_finished() -> void:
	draw_finished.emit()


func yell_uno() -> void:
	UnoManager.yell_uno(player)
