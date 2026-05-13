extends Control
class_name ChallengeMenu

signal choice_maked(choice: bool)

func show_self() -> void:
	self.visible = not self.visible


func make_selection(choice: bool) -> void:
	choice_maked.emit(choice)


func _on_accept_button_pressed() -> void:
	make_selection(false)
	show_self()


func _on_challenge_button_pressed() -> void:
	make_selection(true)
	show_self()
