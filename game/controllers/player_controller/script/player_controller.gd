class_name PlayerController
extends Controller
## Contiene la lógica para controlar el comportamiento de los jugadores humanos durante el juego.

var current_hovered_card: Card = null

# --- Engine Functions ---
func _input(event: InputEvent) -> void:
    var mouse_motion: InputEventMouseMotion

    if event is InputEventMouseMotion:
        mouse_motion = event
    
    if mouse_motion:
        _process_node_hover(_mouse_raycast())


# --- Public Functions ---
## Intenta procesar el turno del jugador actual.
## Si no hay un jugador actual, la función termina sin hacer nada.
func try_to_process_turn() -> void:
    # Si no hay un jugador asignado, terminamos.
    if not _player:
        return
        
    await _process_turn()



# --- Private Functions ---
func _process_turn() -> void:
    await get_tree().create_timer(100).timeout


## Devuelve el nodo 2d que está debajo del mouse
func _mouse_raycast() -> Node2D:
    var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
    var raycast_parameters: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()

    raycast_parameters.position = get_global_mouse_position()
    raycast_parameters.collide_with_areas = true

    var result: Array = space_state.intersect_point(raycast_parameters)

    # Si no hay resultados entonces retornamos null
    if result.is_empty():
        return null

    var node_found: Node2D = (result[0].collider as Area2D).get_parent()

    return node_found


func _process_node_hover(node: Node2D) -> void:
    var card_found: Card
    if node is Card:
        card_found = node
    
    if not card_found:
        return

    if card_found == current_hovered_card:
        return
    
    _change_hover_state(card_found)
    current_hovered_card = card_found



func _change_hover_state(card: Card) -> void:
    if not card:
        return
    
    match card.is_selected:
        true:
            card.is_selected = false
            CardManager.move_card_to_position(card, Vector2(card.position.x, 150), 0.25, 0.0)
        false:
            card.is_selected = true
            CardManager.move_card_to_position(card, Vector2(card.position.x, -150), 0.25, 0.0)
    
    _player.cards_container.allign_cards(_player.current_hand)