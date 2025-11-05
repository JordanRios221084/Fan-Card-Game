extends Node
class_name PlayersContainer

# --- Total de jugadores actuales
var total_current_players: Array[Node]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	total_current_players = get_children()