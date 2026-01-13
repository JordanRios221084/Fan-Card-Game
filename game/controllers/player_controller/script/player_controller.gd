class_name PlayerController
extends Controller
## Contiene la lógica para controlar el comportamiento de los jugadores humanos durante el juego.


# --- Enums ---
## Contiene los estados de hover para las cartas del jugador.
enum HOVER_STATES {
    NONE,
    HOVERING_CARD,
}

# --- Private Variables ---
## Estado actual de hover del jugador.
var _current_hover_state: HOVER_STATES = HOVER_STATES.NONE
## Indica si el controlador está deshabilitado.
var _enabled: bool = false


# --- Engine Functions ---
func _input(event: InputEvent) -> void:
    if not _enabled:
        return
    
    if not event is InputEventMouseButton:
        return
    
    var mouse_event: InputEventMouseButton = event as InputEventMouseButton
    if not mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
        return
    
    var node_under_mouse: Node2D = _mouse_raycast()

    if node_under_mouse and node_under_mouse is Card:
        var card_under_mouse: Card = node_under_mouse as Card
        check_card.emit(card_under_mouse)
        if not card_under_mouse in _player.cards_container.current_hand:
            _enabled = false
    
    if node_under_mouse and node_under_mouse is Deck:
        draw_card.emit(_player)
        await game_manager.draw_card_finished


# --- Public Functions ---
## Intenta procesar el turno del jugador actual.
## Si no hay un jugador actual, la función termina sin hacer nada.
func try_to_process_turn() -> void:
    # Si no hay un jugador asignado, terminamos.
    if not _player:
        return
        
    _process_turn()


# --- Private Functions ---
func _process_turn() -> void:
    _enabled = true

    if _player.cards_container.current_hand.size() == 2:
        two_cards_left.emit(_player) # Emite una señal si el jugador tiene 2 cartas


## Devuelve el nodo 2d que está debajo del mouse
func _mouse_raycast() -> Node2D:
    var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
    var raycast_parameters: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()

    raycast_parameters.position = get_global_mouse_position()
    raycast_parameters.collide_with_areas = true

    var result: Array = space_state.intersect_point(raycast_parameters)
    if result.is_empty():
        return null

    var node_found: Node2D
    if (result[0].collider as Area2D).get_parent() is Card:
        node_found = _get_highest_z_index_card(result)
    else:
        node_found = (result[0].collider as Area2D).get_parent() as Node2D

    return node_found


## Devuelve la carta con el índice Z más alto de una lista de resultados de intersección.
func _get_highest_z_index_card(result: Array) -> Card:
    var highest_z_index_card: Node2D = (result[0].collider as Area2D).get_parent()
    var highest_z_index: int = highest_z_index_card.z_index

    for i: int in range(1, result.size()):
        var current_card: Card = (result[i].collider as Area2D).get_parent() as Card

        if current_card.z_index > highest_z_index:
            highest_z_index_card = current_card
            highest_z_index = current_card.z_index

    return highest_z_index_card


# --- Private Functions ---
func _highlight_card(card: Card, highlight: bool) -> void:
    match highlight:
        true: 
            card.is_selected = highlight
            card.z_index = 1
        false:
            card.is_selected = highlight
            card.z_index = 0
    
    _player.cards_container.allign_cards()


# --- Signal Handlers ---
func _on_card_mouse_entered_card(card: Card) -> void:
    if _current_hover_state == HOVER_STATES.NONE:
        _current_hover_state = HOVER_STATES.HOVERING_CARD
        _highlight_card(card, true)


func _on_card_mouse_exited_card(card: Card) -> void:
    _highlight_card(card, false)

    var new_card_under_mouse: Card = _mouse_raycast() as Card
    if new_card_under_mouse and new_card_under_mouse is Card:
        _highlight_card(new_card_under_mouse, true)
    else:
        _current_hover_state = HOVER_STATES.NONE