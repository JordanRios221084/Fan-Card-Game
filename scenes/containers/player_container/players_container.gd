class_name PlayersContainer
extends Node
## Contenedor que gestiona a todos los nodos de tipo [Player] durante la partida.
##
## Guarda referencias a los jugadores actuales en la escena en un arreglo para facilitar su acceso y manipulación.

# --- Public Variables ---
## Arreglo de nodos que representan a los jugadores actuales en el contenedor.
var current_players: Array[Node] = []

# --- Engine Functions ---
func _ready() -> void:
	# Asigna los hijos actuales al arreglo.
	current_players = get_children()