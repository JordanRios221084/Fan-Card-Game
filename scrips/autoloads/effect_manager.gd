extends Node
## Script responsable del manejo de los efectos de las cartas jugadas.
##
## Parsea strings de efectos (ej: "draw/2_skip/1") y manipula el estado del juego
## a través del GameManager. Debe configurarse como Autoload.

# --- Public Variables ---
## Referencia al GameManager. 
## Se asigna externamente desde el GameManager en su _ready().
var game_manager: GameManager
var _arrow_rotation_direction: float = 1.0
var _arrow_scale_factor: float = -1.0

# --- Engine Functions ---
func _process(delta: float) -> void:
	_process_arrow_rotation(delta)

# --- Public Functions ---
## Procesa la lógica de los efectos de una carta.
## Este método es asíncrono para permitir pausas entre la aplicación de efectos y animaciones. [br]
##
## - [param card_effects]: String que contiene los efectos de la carta separados por "_" (ej: "draw/2"). [br]
## - [param target_player]: Jugador objetivo del efecto.
func process_effect(card_effects: String, target_player: Player) -> void:
	if not game_manager:
		push_error("EffectManager: No hay referencia al GameManager.")
		return

	# Separar múltiples efectos (si existen) usando "_"
	var effect_parameters: PackedStringArray = card_effects.split("_")

	for i: int in range(effect_parameters.size()):
		var current_effect: Dictionary = _parse_effect(effect_parameters[i])
		print("EffectManager: Procesando efecto -> ", current_effect)

		match current_effect.base:
			"skip":
				_apply_skip_effect(current_effect.value)
			"reverse":
				_apply_reverse_effect(current_effect.value)
			"draw":
				await _apply_draw_effect(target_player, current_effect.value)
			"wild":
				print("EffectManager: Efecto Comodín (Wild) - Pendiente de implementación.")
			"challenge":
				print("EffectManager: Efecto Reto (Challenge) - Pendiente de implementación.")
			"stack":
				print("EffectManager: Efecto Acumular (Stack) - Pendiente de implementación.")
			"none", "":
				pass
			_:
				push_warning("EffectManager: Efecto desconocido '%s'" % current_effect.base)
	
	# Pequeña pausa final para separar visualmente la aplicación de efectos del cambio de turno
	await game_manager.get_tree().create_timer(0.5).timeout


# --- Private Functions ---
## Parsea un efecto en su base y valor. [br]
## Ej: "draw/2" -> { "base": "draw", "value": "2" }
func _parse_effect(effect: String) -> Dictionary:
	var result: Dictionary = {
		"base": effect,
		"value": null
	}

	if effect.contains("/"):
		var effect_parts: PackedStringArray = effect.split("/")
		result.base = effect_parts[0]
		# Verificamos que exista la segunda parte antes de asignar
		if effect_parts.size() > 1:
			result.value = effect_parts[1]
	
	return result


## Aplica el efecto de saltar turnos.
## Modifica la variable 'steps' del GameManager.
func _apply_skip_effect(new_steps: String) -> void:
	if new_steps.is_valid_int():
		game_manager.steps = new_steps.to_int()
		print("EffectManager: Saltando %s pasos." % new_steps)


## Aplica el efecto de invertir dirección.
## Modifica la variable 'direction' del GameManager.
func _apply_reverse_effect(new_direction: String) -> void:
	if new_direction and new_direction.is_valid_int():
		game_manager.direction = game_manager.direction * new_direction.to_int()

		# Actualizar parámetros visuales de la flecha
		_set_arrows_parameters(new_direction.to_int())

		print("EffectManager: Dirección invertida.")
	else:
		# Si no hay valor, asumimos inversión estándar (-1)
		game_manager.direction *= -1


## Aplica el efecto de robar cartas.
## Llama a la función de robar del GameManager.
func _apply_draw_effect(target_player: Player, draw_quantity: String) -> void:
	var amount: int = 1
	if draw_quantity and draw_quantity.is_valid_int():
		amount = draw_quantity.to_int()
	
	print("EffectManager: %s roba %d cartas." % [target_player.name, amount])
	
	# Llamamos a draw_a_new_card. Como es async, usamos await aquí también.
	await game_manager.draw_a_new_card(target_player, amount, true, 0.15)


func _set_arrows_parameters(direction: int) -> void:
	_arrow_rotation_direction = _arrow_rotation_direction * direction
	var direction_tween: Tween = create_tween()
	direction_tween.tween_property(game_manager.arrow_indicator, "scale:x", 
			game_manager.arrow_indicator.scale.x * _arrow_scale_factor, 0.5)


func _process_arrow_rotation(delta: float) -> void:
	game_manager.arrow_indicator.rotation += deg_to_rad(55) * _arrow_rotation_direction * delta
