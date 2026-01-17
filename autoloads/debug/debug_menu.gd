extends CanvasLayer


# --- Exported Variables ---
@export var fps_label: Label ## Etiqueta para mostrar los FPS.
@export var toggle_hitboxes_button: CheckBox ## Botón para activar/desactivar la visualización de hitboxes.

# --- Variables ---
var game_tree: SceneTree ## Escena de todo el juego.
var root: Node ## La raiz de la la escena principal.



# -------------------- Engine Functions --------------------

func _ready() -> void:
	game_tree = get_tree()
	root = game_tree.root


func _process(_delta: float) -> void:
	if visible:
		fps_label.text = "FPS: " + str(Engine.get_frames_per_second())


func _input(event: InputEvent) -> void:
	var input_event: InputEventKey = event as InputEventKey
	if input_event and input_event.is_action_pressed("toggle_debug"):
		toggle_menu()





# -------------------- Funciones de Gestión del Menú de Depuración --------------------

## Activa o desactiva la visibilidad del menú de depuración.
func toggle_menu() -> void:
	visible = not visible


## Activa o desactiva la visualización de hitboxes en la escena.
func toggle_hitboxes(enable: bool) -> void:
	game_tree.debug_collisions_hint = enable
	game_tree.call_group("debug_collision", "queue_redraw")


## Voltea todas las cartas de los rivales para poder verlas
func flip_opponent_cards() -> void:
	game_tree.call_group("opponent_cards", "flip_card")


## Señal conectada al botón para activar/desactivar hitboxes.
func _on_button_toggled(toggled_on: bool) -> void:
	toggle_hitboxes(toggled_on)


func _on_button_pressed() -> void:
	flip_opponent_cards()
