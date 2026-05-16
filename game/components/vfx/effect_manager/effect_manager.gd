class_name EffectManager
extends Node2D
## Se encarga de gestionar y aplicar los efectos de las cartas en el juego. [br]
##
## Parsea strings de efectos (ej: "draw/2_skip/1") y manipula el estado del juego
## mediante sus métodos integrados.

# --- Signals ---
signal draw_processed(target_player: Player, amount: int) ## Señal emitida cuando se procesa el efecto de robar cartas.
signal process_wild_selection
signal color_received(color: String)
signal show_wild_menu
signal choice_maked(choice: bool)
signal process_choice
signal check_current_player_cards
signal target_draw_player(player: Player)
signal check_next_player_cards(card: Card)
signal recovered_draw_card(card: Card)
signal current_stack_state(active: bool)

# --- Exported Variables ---
@export_group("References")
@export var background: Background ## Referencia al fondo para cambiar colores.
@export var foreground: Foreground ## Referencia al primer plano para efectos visuales.

@export_group("Instances")
@export var arrow_indicator: ArrowIndicator ## Indicador de flechas para la dirección del juego.

# -- Constants --
## Escena del efecto visual.
const EFFECT_SCENE: PackedScene = preload("res://game/components/vfx/ui_effect/ui_effect.tscn")
## Escena del indicador de flechas.
const ARROW_SCENE: PackedScene = preload("res://game/components/vfx/arrow_indicator/arrow_indicator.tscn")

# --- Variables ---
var disable_visuals: bool = false ## Indica si se deben deshabilitar los efectos visuales temporalmente.
var process_arrows_animation: bool = false ## Indica si se debe animar el indicador de flechas.
var game_manager_steps: int = 1 ## Cantidad de pasos a mover en el turno (1 o más).
var game_manager_direction: int = 1 ## Dirección del turno (1 para sentido horario, -1 para sentido antihorario).
var stacked_draw: int = 0
var screen_center: Vector2 ## Centro de la pantalla para posicionar efectos visuales.
var challenge_rule: bool
var stack_rule: bool


# -------------------- Engine Functions --------------------
func _ready() -> void:
	screen_center = get_viewport_rect().size / 2
	UnoManager.connect("uno_yelled", _on_uno_manager_uno_yelled)
	UnoManager.connect("punished_player", _on_uno_manager_punished_player)


func _process(delta: float) -> void:
	if process_arrows_animation:
		arrow_indicator.rotation += deg_to_rad(90) * delta * game_manager_direction





# -------------------- Funciones de inicio --------------------

## Inicia el indicador de flechas en la escena.
func start_arrows_indicator() -> void:
	arrow_indicator = ARROW_SCENE.instantiate() as ArrowIndicator
	add_child(arrow_indicator)

	arrow_indicator.position = screen_center
	print(arrow_indicator.position)
	arrow_indicator.scale = Vector2.ONE * 3.0
	process_arrows_animation = true

	var opacity_tween: Tween = create_tween()
	var duration: float = 0.5
	var opacity: float = 0.75
	opacity_tween.tween_property(arrow_indicator, "modulate:a", opacity, duration)


func flip_arrows_indicator() -> void:
	var flip_tween: Tween = create_tween()
	var duration: float = 0.5
	flip_tween.tween_property(arrow_indicator, "scale:x", arrow_indicator.scale.x * -1, duration)





# -------------------- Gestión de Efectos de Cartas --------------------

## Procesa la lógica de los efectos de una carta.
## Este método es asíncrono para permitir pausas entre la aplicación de efectos y animaciones. [br]
##
## - [param card_effects]: String que contiene los efectos de la carta separados por "_" (ej: "draw/2"). [br]
## - [param target_player]: Jugador objetivo del efecto.
func process_effect(card: Card, target_player: Player, current_player: Player) -> void:
	var effect_list: Array = card.get_card_effect().split("_")
	var bg_new_color: Color = card.get_card_color()
	card.is_effect_used = true

	background.set_background_color(bg_new_color)

	for i: int in range(effect_list.size()):
		## Efecto actual parseado, contiene su nombre y valor.
		var current_effect: Dictionary = parse_effect(effect_list[i])

		match current_effect.name:
			"skip":
				await skip_effect(target_player)
			"reverse":
				await reverse_effect()
			"draw":
				var choice: bool = false
				var draw_card: Card
				
				if stack_rule:
					check_next_player_cards.emit(card)
					
					draw_card = await recovered_draw_card
				
				if not draw_card:
					if card.values.type == "wild_draw4" and challenge_rule:
						process_choice.emit()
						
						choice = await choice_maked
					
					
					if choice:
						check_current_player_cards.emit()
						
						var new_target_player: Player = await target_draw_player
						
						if new_target_player:
							await draw_effect(new_target_player as Player, int(current_effect.value) + stacked_draw)
							stacked_draw = 0
							stack_state_report()
							break
						else:
							await draw_effect(target_player, int(current_effect.value) + 2 + stacked_draw)
							stacked_draw = 0
							stack_state_report()
					else:
						await draw_effect(target_player, int(current_effect.value) + stacked_draw)
						stacked_draw = 0
						stack_state_report()
				else:
					stacked_draw += int(current_effect.value)
					stack_state_report()
					break
				
				await get_tree().create_timer(0.1).timeout
				
				toggle_visual_effects(true)
			"wild":
				await wild_effect(current_player, card)
			"none":
				pass
			_:
				push_warning("EffectManager: Efecto desconocido: ", current_effect.name)

	toggle_visual_effects(false)
	await get_tree().create_timer(0.5).timeout


## Parsea un efecto en su base y valor. [br]
## Ej: "draw/2" -> { "base": "draw", "value": "2" }
func parse_effect(effect: String) -> Dictionary:
	var result: Dictionary = {
		"name": effect,
		"value": null
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
	game_manager_direction = direction
	game_manager_steps = steps


func set_game_rules(challenge: bool, stack: bool) -> void:
	challenge_rule = challenge
	stack_rule = stack


## Devuelve los parámetros actuales del juego relacionados con los efectos. [br]
## - Retorna un diccionario con las claves "steps" y "direction".
func return_game_parameters() -> Dictionary:
	return {
		"steps": game_manager_steps,
		"direction": game_manager_direction
	}





# -------------------- Funciones de los efectos --------------------

## Aplica el efecto de saltar el turno a un jugador objetivo. [br]
## - [param target_player]: Jugador al que se le aplicará el efecto de salto.
func skip_effect(target_player: Player) -> void:
	game_manager_steps = 2
	set_game_parameters(game_manager_steps, game_manager_direction)

	if disable_visuals:
		return
	
	await create_visual_effect("skip", screen_center, target_player, true)


## Aplica el efecto de invertir la dirección del juego.
func reverse_effect() -> void:
	game_manager_direction = game_manager_direction * -1
	set_game_parameters(game_manager_steps, game_manager_direction)

	if disable_visuals:
		return
	
	await create_visual_effect("reverse", screen_center)
	background.invert_wave_direction()
	flip_arrows_indicator()


## Aplica el efecto de robar cartas a un jugador objetivo. [br]
## - [param target_player]: Jugador al que se le aplicará el efecto de robar cartas. [br]
## - [param amount]: Cantidad de cartas a robar.
func draw_effect(target_player: Player, amount: int) -> void:
	if not disable_visuals:
		await create_visual_effect("draw", screen_center, target_player, true, amount)
	
	draw_processed.emit(target_player, amount)


func wild_effect(player: Player, wild_card: Card) -> void:
	if player.is_human:
		show_wild_menu.emit()
	
	process_wild_selection.emit()
	
	var color: String = await color_received

	await get_tree().create_timer(0.5).timeout
	
	wild_card.set_card_color(color)
	background.set_background_color(color)


func stack_state_report() -> void:
	print("-------------Stack actual:", stacked_draw)
	if stacked_draw > 0:
		current_stack_state.emit(true)
	else:
		current_stack_state.emit(false)


## Habilita o deshabilita los efectos visuales. [br]
## - [param disable]: Si es [true], deshabilita los efectos visuales; si es [false], los habilita.
func toggle_visual_effects(disable: bool) -> void:
	disable_visuals = disable





# -------------------- Funciones de efectos visuales --------------------

## Crea un efecto visual en la escena para representar un efecto aplicado. [br]
## - [param effect_icon]: Nombre del icono del efecto. [br]
## - [param effect_value]: Valor del efecto (ej: cantidad de cartas a robar). [br]
## - [param start_pos]: Posición inicial del efecto visual. [br]
## - [param final_node]: Nodo final al que se moverá el efecto visual.
func create_visual_effect(effect_icon: String, start_pos: Vector2, final_node: Node2D = null, play_burst: bool = false, effect_value: int = 0) -> void:
	var ui_effect: UIEffect = EFFECT_SCENE.instantiate() as UIEffect
	var effect_icon_id: int
	add_child(ui_effect)
	
	match effect_icon:
		"draw":
			effect_icon_id = 0
			ui_effect.set_effect(effect_icon_id, effect_value)
		"skip":
			effect_icon_id = 1
			ui_effect.set_effect(effect_icon_id)
		"reverse":
			effect_icon_id = 2
			ui_effect.set_effect(effect_icon_id)
		"uno":
			effect_icon_id = 3
			ui_effect.set_effect(effect_icon_id)
		"atack":
			effect_icon_id = 4
			ui_effect.set_effect(effect_icon_id)
		_:
			push_warning("EffectManager: Icono de efecto desconocido: ", effect_icon)

	ui_effect.position = start_pos
	ui_effect.scale = Vector2.ONE * 5.0
	ui_effect.z_index = 10

	# Animación inicial: mover a posición (0,0) del nodo destino
	var effect_tween: Tween = create_tween()
	var duration: float = 0.5
	var final_pos: Vector2 = Vector2(0, -50.0)

	if final_node:
		ui_effect.reparent(final_node)
	else:
		final_pos = Vector2(screen_center.x, screen_center.y - 50.0)

	effect_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	effect_tween.tween_property(ui_effect, "position", final_pos, duration)
	await effect_tween.finished

	if play_burst:
		ui_effect.play_burst_effect()
		foreground.play_shockwave_effect(ui_effect.get_global_position())
	
	# Animación final: escalar a cero y eliminar
	effect_tween = create_tween()
	duration = 0.2
	effect_tween.tween_property(ui_effect, "scale", Vector2.ZERO, duration)
	await effect_tween.finished

	ui_effect.queue_free()


func winner_effect(winner: Player) -> void:
	foreground.show_winner(winner)



func _on_uno_manager_uno_yelled(player: Player) -> void:
	create_visual_effect("uno", player.position, player)


func _on_uno_manager_punished_player(victim: Player) -> void:
	create_visual_effect("atack", screen_center, victim, true)
