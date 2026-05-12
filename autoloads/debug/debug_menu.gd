extends CanvasLayer


# --- Exported Variables ---
@export_group("Debug Menu Components")
@export var menu: Control ## Contenedor del menú de depuración.
@export var fps_label: Label ## Etiqueta para mostrar los FPS.
@export var current_player_label: Label ## Etiqueta para mostrar el jugador actual.
@export var next_player_label: Label ## Etiqueta para mostrar el siguiente jugador.
@export var direction_label: Label ## Etiqueta para mostrar la dirección del juego.

@export_group("Console Components")
@export var console: Control ## Contenedor de la consola de comandos.
@export var input_text: LineEdit ## Campo de texto para entrada de comandos.
@export var text_log: RichTextLabel ## Área de texto para mostrar logs.

# --- Variables ---
var game_tree: SceneTree ## Escena de todo el juego.
var root: Node ## La raiz de la la escena principal.
var text_submitted: Array[String] = [] ## Último texto enviado en la consola.
var current_text_index: int = -1 ## Índice del texto actual en el historial de comandos.



# -------------------- Engine Functions --------------------

func _ready() -> void:
	game_tree = get_tree()
	root = game_tree.root

	menu.visible = false
	console.visible = false


func _process(_delta: float) -> void:
	if visible:
		fps_label.text = "FPS: " + str(Engine.get_frames_per_second())


func _input(event: InputEvent) -> void:
	var input_event: InputEventKey = event as InputEventKey
	if input_event and input_event.is_action_pressed("toggle_console"):
		toggle_console()

		if console.visible:
			input_text.grab_focus()
	
	if input_event and input_event.is_action_pressed("last_text") and console.visible:
		get_last_text_submission()





# -------------------- Funciones de Gestión del Menú de Depuración --------------------

## Activa o desactiva la visibilidad del menú de depuración.
func toggle_menu() -> void:
	menu.visible = not menu.visible


## Activa o desactiva la visibilidad de la consola de comandos.
func toggle_console() -> void:
	console.visible = not console.visible


## Activa o desactiva la visualización de hitboxes en la escena.
func toggle_hitboxes() -> void:
	var enable: bool = not game_tree.debug_collisions_hint
	game_tree.debug_collisions_hint = enable
	game_tree.call_group("debug_collision", "queue_redraw")


## Voltea todas las cartas de los rivales para poder verlas
func flip_opponent_cards() -> void:
	game_tree.call_group("opponent_cards", "flip_card")
	game_tree.call_group("players", "change_show_cards")


## Actualiza las etiquetas de los jugadores actual y siguiente.
func update_players_labels(current_player: String, next_player: String) -> void:
	current_player_label.text = str("Jugador Actual: ", current_player)
	next_player_label.text = str("Siguiente Jugador: ", next_player)


## Actualiza la etiqueta de dirección del juego.
func update_direction_label(direction: int) -> void:
	direction_label.text = "Dirección: " + str(direction)





# -------------------- Funciones de Gstión de comandos --------------------


## Añade un nuevo comando al historial de comandos enviados.
func set_text_submission(new_text: String) -> void:
	text_submitted.append(new_text)
	current_text_index = text_submitted.size() - 1


## Añade un nuevo mensaje al log de la consola.
func add_log_message(new_message: String) -> void:
	text_log.append_text(new_message + "\n")
	text_log.scroll_to_line(text_log.get_line_count() - 1)


## Rellena el campo de texto con el último comando enviado.
func get_last_text_submission() -> void:
	if text_submitted.size() == 0:
		return
	
	if current_text_index < 0:
		current_text_index = text_submitted.size() - 1
	
	input_text.text = text_submitted[current_text_index]
	print(current_text_index)
	current_text_index -= 1





# -------------------- Motor de comandos --------------------

## Procesa un comando introducido en la consola.
func process_command(command: String) -> void:
	var parts: PackedStringArray = command.strip_edges().split(" ")
	var command_name: String = parts[0].to_lower()

	match command_name:
		"/debug":
			debug_command(parts)
		"/flipcards":
			flip_opponent_cards()
		_:
			if command_name.contains("/"):
				add_log_message("Comando desconocido: " + command_name)


## Función para el comando "debug".
func debug_command(parts: PackedStringArray) -> void:
	if parts.size() < 2:
		add_log_message("Uso: debug <Option> <Entity>")
		return
	
	var option_name: String = parts[1].to_lower()
	match option_name:
		"menu":
			toggle_menu()
		"hitboxes":
			toggle_hitboxes()
		_:
			add_log_message("Opcion desconocida: " + option_name)





# -------------------- Señales de la consola --------------------

## Señal conectada al campo de texto para entrada de comandos.
func _on_input_text_submitted(new_text: String) -> void:
	input_text.clear()

	if new_text.strip_edges() == "":
		return
	
	set_text_submission(new_text)
	add_log_message(new_text)
	process_command(new_text)
