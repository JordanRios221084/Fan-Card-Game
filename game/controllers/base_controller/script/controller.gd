class_name Controller
extends Node2D
## Clase base para los controladores del juego.


# --- Signals ---
signal play_card(card: Card, player: Player) ## Juega una carta por parte del jugador IA.
signal check_card(card: Card) ## Verifica si una carta IA es válida para jugar.
signal draw_card(player: Player) ## Solicita que el jugador IA robe una carta.
signal two_cards_left(player: Player) ## Avisa al [GameManager] que el jugador actual tiene 2 cartas.

# --- Exported Variables ---
@export_group("References")
@export var game_manager: GameManager ## Referencia al [GameManager] para manejar el estado del juego.
@export var player: Player ## Referencia al jugador asociado a este controlador.


# --- Engine Functions ---
func _ready() -> void:
	player = get_parent() as Player





# ---------------------- Control de Turnos --------------------

## Intenta procesar el turno del jugador actual.
## Si no hay un jugador actual, la función termina sin hacer nada.
func try_to_process_turn() -> void:
	print("Base Controller: try_to_process_turn called.")
	pass





# -------------------- Funciones de emisión de señales --------------------

## Emite la señal para jugar una carta por parte del jugador.
func play_a_card(card_to_play: Card) -> void:
	play_card.emit(card_to_play, player)


## Emite la señal para verificar si una carta es válida para jugar.
func check_a_card(card_to_check: Card) -> void:
	check_card.emit(card_to_check)


## Emite la señal para que el jugador robe una carta.
func draw_a_card() -> void:
	draw_card.emit(player)


## Emite la señal para notificar que el jugador tiene dos cartas restantes.
func notify_two_cards_left() -> void:
	two_cards_left.emit(player)