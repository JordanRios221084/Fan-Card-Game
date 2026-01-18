class_name ManualController
extends Controller
## Contiene la lógica para controlar el comportamiento de los jugadores humanos durante el juego.


# --- Enums ---
## Contiene los estados de hover para las cartas del jugador.
enum HOVER_STATES {
    NONE,
    HOVERING_CARD,
}

# --- Variables ---
var current_hover_state: HOVER_STATES = HOVER_STATES.NONE ## Estado actual de hover del jugador.
var enabled: bool = false ## Indica si el controlador está deshabilitado.


# --- Engine Functions ---
func _input(event: InputEvent) -> void:
    if not enabled:
        return
    
    if not event is InputEventMouseButton:
        return
    
    if DebugMenu.console.visible:
        return
    
    var mouse_event: InputEventMouseButton = event as InputEventMouseButton
    if not mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
        return
    
    var node_under_mouse: Node2D = mouse_raycast()

    if node_under_mouse and node_under_mouse is Card:
        var card_under_mouse: Card = node_under_mouse as Card
        card_play(card_under_mouse)
        if not card_under_mouse in player.cards_container.current_hand:
            enabled = false
    
    if node_under_mouse and node_under_mouse is Deck:
        await card_draw()


# --- Private Functions ---
func try_to_process_turn() -> void:
    enabled = true

    if player.cards_container.current_hand.size() == 2:
        notify_two_cards_left()


## Devuelve el nodo 2d que está debajo del mouse
func mouse_raycast() -> Node2D:
    var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
    var raycast_parameters: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()

    raycast_parameters.position = get_global_mouse_position()
    raycast_parameters.collide_with_areas = true

    var result: Array = space_state.intersect_point(raycast_parameters)
    if result.is_empty():
        return null

    var node_found: Node2D
    if (result[0].collider as Area2D).get_parent() is Card:
        node_found = get_highest_z_index_card(result)
    else:
        node_found = (result[0].collider as Area2D).get_parent() as Node2D

    return node_found


## Devuelve la carta con el índice Z más alto de una lista de resultados de intersección.
func get_highest_z_index_card(result: Array) -> Card:
    var highest_z_index_card: Node2D = (result[0].collider as Area2D).get_parent()
    var highest_z_index: int = highest_z_index_card.z_index

    for i: int in range(1, result.size()):
        var current_card: Card = (result[i].collider as Area2D).get_parent() as Card

        if current_card.z_index > highest_z_index:
            highest_z_index_card = current_card
            highest_z_index = current_card.z_index

    return highest_z_index_card





# -------------------- Manejo de Hover en Cartas --------------------

## Resalta o desresalta una carta según el estado de resaltado proporcionado.
func highlight_card(card: Card, highlight: bool) -> void:
    var scale_up: float = 3.15
    var scale_down: float = 3

    match highlight:
        true: 
            card.is_selected = highlight
            card.z_index = 1
            card.scale = Vector2(scale_up, scale_up)
        false:
            card.is_selected = highlight
            card.z_index = 0
            card.scale = Vector2(scale_down, scale_down)
    
    player.cards_container.allign_cards()


# --- Signal Handlers ---
func _on_card_mouse_entered_card(card: Card) -> void:
    if current_hover_state == HOVER_STATES.NONE:
        current_hover_state = HOVER_STATES.HOVERING_CARD
        highlight_card(card, true)


func _on_card_mouse_exited_card(card: Card) -> void:
    highlight_card(card, false)

    var new_card_under_mouse: Card = mouse_raycast() as Card
    if new_card_under_mouse and new_card_under_mouse is Card:
        highlight_card(new_card_under_mouse, true)
    else:
        current_hover_state = HOVER_STATES.NONE