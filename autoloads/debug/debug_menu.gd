extends CanvasLayer


@export var fps_label: Label ## Etiqueta para mostrar los FPS.
@export var toggle_hitboxes_button: CheckBox ## Botón para activar/desactivar la visualización de hitboxes.


# -------------------- Engine Functions --------------------

func _ready() -> void:
	pass # Replace with function body.


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
	var game_tree: SceneTree = get_tree()
	var root: Node = game_tree.root

	game_tree.debug_collisions_hint = enable

	_force_update_collision_shapes(root)


## Función recursiva para forzar el redibujado de las formas de colisión.
func _force_update_collision_shapes(node: Node) -> void:
	# Si es una forma de colisión, forzamos el redibujado
	if node is CollisionShape2D or node is CollisionPolygon2D:
		var canvas_node: CanvasItem = node as CanvasItem
		canvas_node.queue_redraw()

	# Repetir para todos los hijos
	for child: Node in node.get_children():
		_force_update_collision_shapes(child)


## Señal conectada al botón para activar/desactivar hitboxes.
func _on_button_toggled(toggled_on: bool) -> void:
	toggle_hitboxes(toggled_on)
