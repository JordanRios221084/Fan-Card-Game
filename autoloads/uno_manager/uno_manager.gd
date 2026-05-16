extends Node
# Autoload: UnoManager

# --- SEÑALES ---
# La UI solo escucha esta señal para saber si mostrar/ocultar el botón de "Desafiar UNO"
signal vulnerability_state_changed(is_someone_vulnerable: bool)
signal punished_player(victim: Player)
signal uno_yelled(player: Player)

# --- ESTADO INTERNO ---
var vulnerable_player: Player = null
var current_player_yelled_safe: bool = false

# --- FUNCIONES CORE ---

# 1. Se llama ANTES de tirar la carta (si el jugador presiona el botón "UNO" preventivo)
func yell_uno(player: Player) -> void:
	if player.cards_container.current_hand.size() > 2:
		return
	
	uno_yelled.emit(player)
	
	current_player_yelled_safe = true
	print(player.name + " gritó UNO a tiempo.")
	
	# Si por alguna razón estaba vulnerable, lo salvamos
	if vulnerable_player == player:
		clear_vulnerability()

# 2. Se llama automáticamente cuando cualquier jugador juega una carta
func check_post_play_state(player: Player, cards_left: int) -> void:
	if cards_left == 1:
		if current_player_yelled_safe:
			# Jugó bien, gritó antes o justo a tiempo.
			clear_vulnerability()
		else:
			# ¡Peligro! Se quedó con 1 carta y no ha gritado. Queda expuesto.
			vulnerable_player = player
			vulnerability_state_changed.emit(true)
			print("ALERTA: " + player.name + " está vulnerable a desafío.")
	else:
		# Tiene más de 1 carta o ya ganó (0 cartas). Reseteamos el estado seguro.
		current_player_yelled_safe = false
		if vulnerable_player == player:
			clear_vulnerability()

# 3. La función que llama el botón rojo de "Desafiar" en la UI
func challenge_uno(challenger: Player) -> void:
	if vulnerable_player != null and vulnerable_player != challenger:
		print(challenger.name + " atrapó a " + vulnerable_player.name + "!")
		punish_player(vulnerable_player)
	else:
		print("Desafío inválido o el jugador intentó auto-desafiarse (Denegado).")

# 4. El Castigo (El +2 por no decir UNO)
func punish_player(target: Player) -> void:
	punished_player.emit(target)
	# Aquí llamas a tu lógica de robar cartas
	print(target.name + " recibió 2 cartas de castigo.")
	clear_vulnerability()

# 5. Limpieza del estado
func clear_vulnerability() -> void:
	vulnerable_player = null
	current_player_yelled_safe = false
	vulnerability_state_changed.emit(false)
