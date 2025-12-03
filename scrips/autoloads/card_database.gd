# --- Autoload para obtener la base de datos de cartas ---
extends Node
## Script para cargar y proporcionar acceso a la base de datos de cartas desde un archivo CSV.

var _card_db: Array[CardValues] = []
var _csv_path: String = "res://data/classic.csv"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_load_card_database(_csv_path)

## Método privado. [br]
## Carga la base de datos de cartas desde un archivo CSV. [br]
## Parametros: [br]
## [param path]: La ruta del archivo CSV que contiene la base de datos de cartas.
func _load_card_database(path: String) -> void:
	# --- Cargar la base de datos de cartas desde un archivo CSV ---
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("No se pudo abrir el archivo de la base de datos de cartas: %s" % path)
		return
	
	file.get_csv_line() # Saltar la línea de encabezado

	while not file.eof_reached():
		# Leer una línea del archivo CSV
		var line: PackedStringArray = file.get_csv_line()
		var values: Array = line[0].split(";")

		# Validar que la línea tenga el número correcto de valores
		if values.size() < 5:
			push_warning("Línea inválida en la base de datos de cartas: %s" % line)
			continue
		
		# Crear una nueva instancia del recurso CardValues
		var card_value: CardValues = CardValues.new()

		# Asignar valores a las propiedades del recurso CardValues
		card_value.card_id = values[0]
		card_value.card_type = values[1]
		card_value.card_symbol = values[2]
		card_value.card_color = values[3]
		card_value.card_effect = values[4]
		
		# Añadir el recurso CardValues a la base de datos de cartas
		_card_db.append(card_value)

## Método para obtener la base de datos de cartas. [br]
## Retorna: Una copia de la base de datos de cartas.
func get_card_database() -> Array:
	return _card_db.duplicate()
