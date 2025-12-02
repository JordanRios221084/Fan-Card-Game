extends Node
class_name PlayersContainer
## [b]Descripción:[/b] Contenedor de jugadores que maneja la lista de jugadores en el juego. [br]
## Contiene una propiedad para almacenar los jugadores actuales.

# --- Total de jugadores actuales
var total_current_players: Array[Node] ## Lista de nodos que representan a los jugadores actuales en el contenedor.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	total_current_players = get_children()