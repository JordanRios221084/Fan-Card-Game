class_name CardValues
extends Node
## Estructura de datos para almacenar los valores de la carta. [br]
## Los campos disponibles son: "ID", "Type", "Symbol", "Color", "Effect", "TargetColor".

## ID único de la carta
@export var id: String
## Tipo de la carta
@export var type: String
## Simbolo de la carta
@export var symbol: int
## Nombre del color de la carta
@export var color: String
## Cadena de efectos de la carta
@export var effect: String
## Color visual de la carta
@export var target_color: Color
