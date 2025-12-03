class_name CardValues
extends Resource
## Recurso de valores de la carta.
##
## Almacena los datos puros que definen una carta, separado de su representación visual.
## Se utiliza para pasar información entre el Mazo, el Constructor y los Jugadores.

# --- Exported Properties ---
## Identificador único de la carta (ej: "red_01", "wild_color").
@export var card_id: String
## Tipo de carta. Los tipos pueden ser "number" (número), "action" (acción), "wild" (comodín), etc.
@export var card_type: String
## Color de la carta. Valores esperados: "red", "blue", "green", "yellow", "black".
@export var card_color: String
## Símbolo o número de la carta. Usar un valor específico (ej. -1) si no tiene número.
@export var card_symbol: int
## Efecto especial de la carta (ej: "skip", "draw_two", "none").
@export var card_effect: String