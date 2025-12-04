extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var all_cards: Array = get_children()

	await get_tree().create_timer(1.0).timeout
	CardManager.card_scale_down(all_cards[0])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
