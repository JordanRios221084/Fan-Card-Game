class_name PlayersContainer
extends Node
## Contenedor que gestiona a todos los nodos de tipo [Player] durante la partida.
##
## Guarda referencias a los jugadores actuales en la escena en un arreglo para facilitar su acceso y manipulación.

# --- Private Variables ---
## Arreglo de nodos que representan a los jugadores actuales en el contenedor.
var _current_players: Array[Node] = []

# --- Engine Functions ---
func _ready() -> void:
	# Asigna los hijos actuales al arreglo.
	_current_players = get_children()

# --- Public Functions ---
## Devuelve el arreglo de jugadores actuales en el contenedor.
func get_current_players() -> Array[Player]:
	var players: Array[Player] = []

	for player: Player in _current_players:
		if player is Player:
			players.append(player)
	
	return players