# --- Autoload para obtener la base de datos de cartas ---
extends Node
## Script para cargar y proporcionar acceso a la base de datos de cartas desde un archivo CSV.

# --- Private Variables ---
## Almacena la base de datos de cartas cargada.
var _card_db: Array[Dictionary] = []
## Ruta al archivo CSV que contiene la base de datos de cartas.
var _csv_path: String = "res://data/classic.csv"


# --- Engine Functions ---
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_load_card_database(_csv_path)


# --- Private Functions ---
## Carga la base de datos de cartas desde un archivo CSV. [br]
## Parametros: [br]
## - [param path]: La ruta del archivo CSV que contiene la base de datos de cartas.
func _load_card_database(path: String) -> void:
	var _file: FileAccess = FileAccess.open(path, FileAccess.READ)

	if not _file:
		push_error("No se pudo abrir el archivo de la base de datos de cartas: %s" % path)
		return
	
	_file.get_csv_line() # Saltar la línea de encabezado

	while not _file.eof_reached():
		var _line: PackedStringArray = _file.get_csv_line()
		var _csv_values: Array = _line[0].split(";")

		if _csv_values.size() < 5:
			push_warning("Línea inválida en la base de datos de cartas: %s" % _line)
			continue
		
		var _card_data: Dictionary = {}

		# Asignar valores a las propiedades de la clase CardData
		_card_data["ID"] = _csv_values[0]
		_card_data["Type"] = _csv_values[1]
		_card_data["Symbol"] = _csv_values[2]
		_card_data["Color"] = _csv_values[3]
		_card_data["Effect"] = _csv_values[4]
		
		_card_db.append(_card_data)


# --- Public Functions ---
## Devuelve una copia de la base de datos de cartas cargada.
func get_card_database() -> Array:
	return _card_db.duplicate()
