extends Node

var game_manager: GameManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func process_effect(card_effects: String, target_player: Player) -> void:
	var effect_parameters: PackedStringArray = card_effects.split("_")

	for i: int in range(effect_parameters.size()):
		var current_effect: Dictionary = parse_effect(effect_parameters[i])
		print(current_effect)

		match current_effect.base:
			"skip":
				print("skip")
				skip_effect(current_effect.value)
			"reverse":
				print("reverse")
				reverse_effect(current_effect.value)
			"draw":
				print("draw")
				draw_effect(target_player, current_effect.value)
			"wild":
				print("wild")
			"challenge":
				print("challenge")
			"stack":
				print("stack")
			_:
				print("none")
	
	await get_tree().create_timer(0.5).timeout

func parse_effect(effect: String) -> Dictionary:
	var result: Dictionary = {
		"base": effect,
		"value": null
	}

	if effect.contains("/"):
		var effect_parts: PackedStringArray = effect.split("/")
		result.base = effect_parts[0]
		result.value = effect_parts[1]
	else:
		result.base = effect
		result.value = null
	
	return result

func skip_effect(new_steps: String) -> void:
	game_manager.steps = new_steps.to_int()

func reverse_effect(new_direction: String) -> void:
	game_manager.direction = game_manager.direction * new_direction.to_int()

func draw_effect(target_player: Player, draw_quantity: String) -> void:
	game_manager.draw_a_new_card(target_player, draw_quantity.to_int(), true, 0.15)

func stack_effect(next_player: Player) -> bool:
	return false