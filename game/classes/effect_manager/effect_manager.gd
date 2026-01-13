class_name EffectManager
extends Node2D
## Se encarga de gestionar y aplicar los efectos de las cartas en el juego. [br]
##
## Parsea strings de efectos (ej: "draw/2_skip/1") y manipula el estado del juego
## mediante sus métodos integrados.

# --- Public Signals ---
signal draw_processed(target_player: Player, amount: int) ## Señal emitida cuando se procesa el efecto de robar cartas.

# -- Private Constants --
## Escena del efecto visual.
const  _EFFECT_SCENE: PackedScene = preload("res://game/components/effects/ui_effect/scene/ui_effect.tscn")
## Escena del indicador de flechas.
const _ARROW_SCENE: PackedScene = preload("res://game/components/effects/arrow_indicator/scene/arrow_indicator.tscn")
## Tiempo de transición para los efectos visuales.
const _TRANSITION_TIME_SECONDS: float = 0.3
## Diferencia de color para el fondo.
const _COLOR_DIFFERENCE: float = 0.7

# --- Private Variables ---
var _game_steps: int = 1 ## Cantidad de pasos a mover en el turno (1 o más).
var _game_direction: int = 1 ## Dirección del turno (1 para sentido horario, -1 para sentido antihorario).
var _arrow_indicator: ArrowIndicator ## Indicador de flechas para la dirección del juego.
var _background: Background ## Referencia al fondo para cambiar colores.
var _foreground: Foreground ## Referencia al primer plano para efectos visuales.
var _background_new_color: Color ## Nuevo color de fondo a establecer.
var _disable_visuals: bool = false ## Indica si se deben deshabilitar los efectos visuales temporalmente.

# --- Engine Functions ---
func _ready() -> void:
	_create_arrow_indicator()


func _process(delta: float) -> void:
	_arrow_indicator.rotation += deg_to_rad(90) * delta * _game_direction


# --- Public Functions ---
## Procesa la lógica de los efectos de una carta.
## Este método es asíncrono para permitir pausas entre la aplicación de efectos y animaciones. [br]
##
## - [param card_effects]: String que contiene los efectos de la carta separados por "_" (ej: "draw/2"). [br]
## - [param target_player]: Jugador objetivo del efecto.
func process_effect(card_effects: String, target_player: Player) -> void:
	var effect_list: Array = card_effects.split("_")

	_background.set_background_color(_background_new_color, _TRANSITION_TIME_SECONDS, _COLOR_DIFFERENCE)

	for i: int in range(effect_list.size()):
		## Efecto actual parseado, contiene su nombre y valor.
		var current_effect: Dictionary = _parse_effect(effect_list[i])

		match current_effect["Name"]:
			"skip":
				_game_steps = await _apply_skip_effect(current_effect["Value"], target_player)
			"reverse":
				_game_direction = await _apply_reverse_effect(current_effect["Value"])
				_change_arrow_direction()
			"draw":
				_disable_visuals = true
				await _apply_draw_effect(target_player, current_effect["Value"])
			"wild":
				print("EffectManager: Efecto Comodín (Wild) - Pendiente de implementación.")
			"challenge":
				print("EffectManager: Efecto Reto (Challenge) - Pendiente de implementación.")
			"stack":
				print("EffectManager: Efecto Acumular (Stack) - Pendiente de implementación.")
			"none":
				pass
			_:
				push_warning("EffectManager: Efecto desconocido '%s'" % current_effect["Name"])
	
	_disable_visuals = false
	await get_tree().create_timer(0.5).timeout


## Establece los parámetros del juego para los efectos. [br]
## - [param steps]: Cantidad de pasos a mover en el turno (1 o más). [br]
## - [param direction]: Dirección del turno (1 para sentido horario, -1 para sentido antihorario).
func set_game_parameters(steps: int, direction: int, bg: Background, fg: Foreground, new_color: Color) -> void:
	_game_steps = steps
	_game_direction = direction
	_background = bg
	_foreground = fg
	_background_new_color = new_color

## Obtiene los parámetros actuales del juego relacionados con los efectos. [br]
## - Retorna un diccionario con las claves "steps" y "direction".
func get_game_parameters() -> Dictionary:
	return {
		"Steps": _game_steps,
		"Direction": _game_direction
	}


## Establece la opacidad del indicador de flechas. [br]
## - [param opacity]: Valor de opacidad entre 0.0 (transparente) y 1.0 (opaco).
func set_arrows_opacity(opacity: float) -> void:
	var timeout: float = 0.5
	var opacity_tween: Tween = create_tween()
	opacity_tween.tween_property(_arrow_indicator, "modulate:a", opacity, timeout)


func play_uno_effect(target_player: Player) -> void:
	var uno_icon: int = 3
	var play_burst: bool = false
	var on_player: bool = true

	await _create_ui_effect(0, uno_icon, target_player, play_burst, on_player) # Icono de UNO


## Crea e inicializa el indicador de flechas en la escena.
func _create_arrow_indicator() -> void:
	_arrow_indicator = _ARROW_SCENE.instantiate()
	add_child(_arrow_indicator)
	_arrow_indicator.scale = Vector2(3.0, 3.0)
	_arrow_indicator.modulate.a = 0.0


# --- Private Functions ---
## Parsea un efecto en su base y valor. [br]
## Ej: "draw/2" -> { "base": "draw", "value": "2" }
func _parse_effect(effect: String) -> Dictionary:
	var result: Dictionary = {
		"Name": effect,
		"Value": null
	}

	if effect.contains("/"):
		var effect_parts: PackedStringArray = effect.split("/")
		result["Name"] = effect_parts[0]
		# Verificamos que exista la segunda parte antes de asignar
		if effect_parts.size() > 1:
			result["Value"] = effect_parts[1]
	
	return result


## Aplica el efecto de robar cartas.
## Emite una señal que el [GameManager] escucha
func _apply_draw_effect(target_player: Player, draw_quantity: String) -> void:
	if not target_player or not draw_quantity:
		push_warning("EffectManager: Parámetros inválidos para el efecto de robar cartas.")
		return
	
	var amount: int = draw_quantity.to_int()
	var draw_icon: int = 0
	var play_burst: bool = true
	
	draw_processed.emit(target_player, amount)

	await _create_ui_effect(amount, draw_icon, target_player, play_burst, false) # Icono de robar cartas


## Aplica el efecto de saltar turnos.
## Modifica la variable 'steps' del GameManager.
func _apply_skip_effect(new_steps: String, target_player: Player) -> int:
	if not _disable_visuals:
		var skip_icon: int = 1
		var play_burst: bool = true

		await _create_ui_effect(0, skip_icon, target_player, play_burst, false) # Icono de salto
		
	return new_steps.to_int()


## Aplica el efecto de invertir dirección.
## Modifica la variable 'direction' del GameManager.
func _apply_reverse_effect(new_direction: String) -> int:
	var reverse_icon: int = 2
	var not_play_burst: bool = false

	await _create_ui_effect(0, reverse_icon, null, not_play_burst, false) # Icono de reversa
	_background.invert_wave_direction()

	return _game_direction * new_direction.to_int()


## Crea y añade un efecto visual a la escena.
func _create_ui_effect(value: int, icon: int, target_player: Player, play_burst: bool, on_player: bool) -> void:
	var visual_effect: UIEffect = _EFFECT_SCENE.instantiate() as UIEffect
	add_child(visual_effect) # Añadir a la escena

	# Configurar el efecto visual
	visual_effect.set_effect(value, icon)
	visual_effect.scale = Vector2(5.0, 5.0)
	visual_effect.z_index = 1000

	if target_player:
		visual_effect.reparent(target_player) # Hacer hijo del jugador objetivo
	
	if on_player:
		visual_effect.position = Vector2.ZERO

	# Animaciones de entrada
	var effect_tween: Tween = create_tween()
	effect_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	effect_tween.tween_property(visual_effect, "position", Vector2(0, -50), 0.2)
	await effect_tween.finished

	if play_burst:
		visual_effect.play_burst_effect()
		_foreground.play_shockwave_effect(visual_effect.get_global_position())

	await get_tree().create_timer(0.5).timeout # Pausa para mostrar el efecto

	# Animaciones de salida
	effect_tween = create_tween()
	effect_tween.tween_property(visual_effect, "scale", Vector2(0, 0), 0.2)
	await effect_tween.finished

	visual_effect.queue_free()


## Cambia la dirección del indicador de flechas.
func _change_arrow_direction() -> void:
	var new_direction: float = _arrow_indicator.scale.x * -1
	var change_speed: float = 0.5
	
	var direction_tween: Tween = create_tween()
	direction_tween.tween_property(_arrow_indicator, "scale:x", new_direction, change_speed)