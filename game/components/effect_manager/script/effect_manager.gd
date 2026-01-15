class_name EffectManager
extends Node2D
## Se encarga de gestionar y aplicar los efectos de las cartas en el juego. [br]
##
## Parsea strings de efectos (ej: "draw/2_skip/1") y manipula el estado del juego
## mediante sus métodos integrados.

# --- Signals ---
signal draw_processed(target_player: Player, amount: int) ## Señal emitida cuando se procesa el efecto de robar cartas.

# --- Exported Variables ---
@export_group("References")
@export var background: Background ## Referencia al fondo para cambiar colores.
@export var foreground: Foreground ## Referencia al primer plano para efectos visuales.

@export_group("Instances")
@export var arrow_indicator: ArrowIndicator ## Indicador de flechas para la dirección del juego.

# -- Constants --
## Escena del efecto visual.
const EFFECT_SCENE: PackedScene = preload("res://game/components/effects/ui_effect/scene/ui_effect.tscn")
## Escena del indicador de flechas.
const ARROW_SCENE: PackedScene = preload("res://game/components/effects/arrow_indicator/scene/arrow_indicator.tscn")
const TRANSITION_TIME_SECONDS: float = 0.3 ## Tiempo de transición para los efectos visuales.
const COLOR_DIFFERENCE: float = 0.7 ## Diferencia de color para el fondo.

# --- Variables ---
var process_arrows_animation: bool = false ## Indica si se debe animar el indicador de flechas.
var game_manager_steps: int = 1 ## Cantidad de pasos a mover en el turno (1 o más).
var game_manager_direction: int = 1 ## Dirección del turno (1 para sentido horario, -1 para sentido antihorario).
var bg_new_color: Color ## Nuevo color de fondo a establecer.
var disable_visuals: bool = false ## Indica si se deben deshabilitar los efectos visuales temporalmente.


# --- Engine Functions ---
func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if process_arrows_animation:
		arrow_indicator.rotation += deg_to_rad(90) * delta * game_manager_direction





# -------------------- Funciones de inicio --------------------

## Inicia el indicador de flechas en la escena.
func start_arrows_indicator() -> void:
	arrow_indicator = ARROW_SCENE.instantiate() as ArrowIndicator
	add_child(arrow_indicator)

	arrow_indicator.position = Vector2.ZERO
	process_arrows_animation = true

	var opacity_tween: Tween = create_tween()
	var duration: float = 0.3
	var opacity: float = 0.75
	opacity_tween.tween_property(arrow_indicator, "modulate:a", opacity, duration)










# -------------------- Gestión de Efectos de Cartas --------------------

## Procesa la lógica de los efectos de una carta.
## Este método es asíncrono para permitir pausas entre la aplicación de efectos y animaciones. [br]
##
## - [param card_effects]: String que contiene los efectos de la carta separados por "_" (ej: "draw/2"). [br]
## - [param target_player]: Jugador objetivo del efecto.
func process_effect(card: Card, target_player: Player) -> void:
	var effect_list: Array = card.get_card_effect().split("_")
	card.is_effect_used = true

	background.set_background_color(bg_new_color, TRANSITION_TIME_SECONDS, COLOR_DIFFERENCE)

	for i: int in range(effect_list.size()):
		## Efecto actual parseado, contiene su nombre y valor.
		var current_effect: Dictionary = parse_effect(effect_list[i])

		match current_effect.name:
			"skip":
				print("EffectManager: Efecto Saltar (Skip) - Pendiente de implementación.")
			"reverse":
				print("EffectManager: Efecto Reverso (Reverse) - Pendiente de implementación.")
			"draw":
				print("EffectManager: Efecto Robar (Draw) - Pendiente de implementación.")
			"wild":
				print("EffectManager: Efecto Comodín (Wild) - Pendiente de implementación.")
			"challenge":
				print("EffectManager: Efecto Reto (Challenge) - Pendiente de implementación.")
			"stack":
				print("EffectManager: Efecto Acumular (Stack) - Pendiente de implementación.")
			"none":
				pass
			_:
				push_warning("EffectManager: Efecto desconocido: ", current_effect.name)
	
	await get_tree().create_timer(0.5).timeout


## Parsea un efecto en su base y valor. [br]
## Ej: "draw/2" -> { "base": "draw", "value": "2" }
func parse_effect(effect: String) -> Dictionary:
	var result: Dictionary = {
		"Name": effect,
		"Value": null
	}

	if effect.contains("/"):
		var effect_parts: PackedStringArray = effect.split("/")
		result.name = effect_parts[0]

		# Verificamos que exista la segunda parte antes de asignar
		if effect_parts.size() > 1:
			result.value = effect_parts[1]
	
	return result




# -------------------- Gestión de Parámetros del Juego --------------------

## Establece los parámetros del juego necesarios para procesar los efectos. [br]
## - [param steps]: Cantidad de pasos a mover en el turno (1 o más). [br]
## - [param direction]: Dirección del turno (1 para sentido horario, -1 para sentido antihorario).
func set_game_parameters(steps: int, direction: int) -> void:
	game_manager_steps = steps
	game_manager_direction = direction


## Devuelve los parámetros actuales del juego relacionados con los efectos. [br]
## - Retorna un diccionario con las claves "steps" y "direction".
func return_game_parameters() -> Dictionary:
	return {
		"steps": game_manager_steps,
		"direction": game_manager_direction
	}