extends Node2D
class_name WildMenu

signal color_selected(color: String)

@export_group("Botones")
@export var button_red: TextureButton
@export var button_blue: TextureButton
@export var button_green: TextureButton
@export var button_yellow: TextureButton

@export var all_buttons: Array[TextureButton]

func _ready() -> void:
	all_buttons.append(button_red)
	all_buttons.append(button_blue)
	all_buttons.append(button_green)
	all_buttons.append(button_yellow)


func button_action(btn_name: String) -> void:
	color_selected.emit(btn_name)
	print(btn_name)
	hide_self()


func show_self() -> void:
	self.visible = true
	
	var modulate_tween: Tween = create_tween()
	modulate_tween.tween_property(self, "modulate:a", 1.0, 0.2)
	await modulate_tween.finished
	
	for button: TextureButton in all_buttons:
		button.disabled = false


func hide_self() -> void:
	for button: TextureButton in all_buttons:
		button.disabled = true
	
	var modulate_tween: Tween = create_tween()
	modulate_tween.tween_property(self, "modulate:a", 1.0, 0.2)
	await modulate_tween.finished
	
	self.visible = false

func _on_red_button_pressed() -> void:
	button_action("red")

func _on_blue_button_pressed() -> void:
	button_action("blue")

func _on_green_button_pressed() -> void:
	button_action("green")

func _on_yellow_button_pressed() -> void:
	button_action("yellow")
