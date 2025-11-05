extends Node
class_name AIController

signal check_card(target_card: Card)
signal play_card(found_card: Card)
signal draw_card

var ai_players: Array = []
var current_ai_player: Player

var valid_cards: Array = []
var current_card: Card

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func process_turn() -> void:	
	for player: Player in ai_players:
		if player.is_turn:
			current_ai_player = player
			break
	
	if not current_ai_player:
		return
	
	var random_wait_time: float = randf_range(0.5, 2)

	await get_tree().create_timer(random_wait_time).timeout

	for card: Card in current_ai_player.current_hand:
		emit_signal("check_card", card)

	await get_tree().create_timer(random_wait_time).timeout

	if valid_cards.is_empty():
		return
	

#func play_selected_card()