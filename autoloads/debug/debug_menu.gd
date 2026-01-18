extends CanvasLayer


# --- Exported Variables ---
@export_group("Debug Menu Components")
@export var menu: Control ## Contenedor del menú de depuración.
@export var fps_label: Label ## Etiqueta para mostrar los FPS.
@export var toggle_hitboxes_button: CheckBox ## Botón para activar/desactivar la visualización de hitboxes.

@export_group("Console Components")
@export var console: Control ## Contenedor de la consola de comandos.
@export var input_text: LineEdit ## Campo de texto para entrada de comandos.
@export var text_log: RichTextLabel ## Área de texto para mostrar logs.

# --- Variables ---
var game_tree: SceneTree ## Escena de todo el juego.
var root: Node ## La raiz de la la escena principal.
var last_text_submitted: Array[String] = [] ## Último texto enviado en la consola.



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
	
	if input_event and input_event.is_action_pressed("get_last_text_submitted") and console.visible:
		get_last_text_submission()





# -------------------- Funciones de Gestión del Menú de Depuración --------------------

## Activa o desactiva la visibilidad del menú de depuración.
func toggle_menu() -> void:
	menu.visible = not menu.visible


## Activa o desactiva la visualización de hitboxes en la escena.
func toggle_hitboxes(enable: bool) -> void:
	game_tree.debug_collisions_hint = enable
	game_tree.call_group("debug_collision", "queue_redraw")


## Voltea todas las cartas de los rivales para poder verlas
func flip_opponent_cards() -> void:
	game_tree.call_group("opponent_cards", "flip_card")
	game_tree.call_group("players", "change_show_cards")





# -------------------- Señales del Menú de Depuración --------------------

## Señal conectada al botón para activar/desactivar hitboxes.
func _on_button_toggled(toggled_on: bool) -> void:
	toggle_hitboxes(toggled_on)


func _on_button_pressed() -> void:
	flip_opponent_cards()





# -------------------- Funciones de Gstión de comandos --------------------

## Activa o desactiva la visibilidad de la consola de comandos.
func toggle_console() -> void:
	console.visible = not console.visible


## Rellena el campo de texto con el último comando enviado.
func get_last_text_submission() -> void:
	if last_text_submitted.size() == 0:
		return
	
	var current_text: String = input_text.text
	if current_text in last_text_submitted:
		var current_index: int = last_text_submitted.find(current_text)
		var next_index: int = (current_index + 1) % last_text_submitted.size()
		input_text.text = last_text_submitted[next_index]
	else:
		input_text.text = last_text_submitted[last_text_submitted.size() - 1]


## Añade un nuevo comando al historial de comandos enviados.
func set_last_text_submission(new_text: String) -> void:
	last_text_submitted.append(new_text)


## Añade un nuevo mensaje al log de la consola.
func add_log_message(new_message: String) -> void:
	text_log.append_text(new_message + "\n")
	text_log.scroll_to_line(text_log.get_line_count() - 1)


## Procesa un comando introducido en la consola.
func process_command(command: String) -> void:
	var parts: PackedStringArray = command.strip_edges().split(" ")
	var command_name: String = parts[0].to_lower()

	match command_name:
		"toggle":
			toggle_command(parts)
		_:
			add_log_message("Comando desconocido: " + 
			parts[0])
	
	
	input_text.grab_focus()


## Función para el comando "toggle".
func toggle_command(parts: PackedStringArray) -> void:
	if parts.size() < 2:
		add_log_message("Uso: toggle <entity>")
		return
	
	var entity: String = parts[1].to_lower()
	match entity:
		"debugmenu", "debug_menu":
			toggle_menu()
		_:
			add_log_message("Entidad desconocida: " + entity)





# -------------------- Señales de la consola --------------------

## Señal conectada al campo de texto para entrada de comandos.
func _on_input_text_submitted(new_text: String) -> void:
	input_text.clear()

	if new_text.strip_edges() == "":
		input_text.grab_focus()
		return
	
	set_last_text_submission(new_text)
	add_log_message(new_text)
	process_command(new_text)