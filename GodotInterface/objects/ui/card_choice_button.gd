extends Button
class_name CardChoiceButton


func _ready() -> void:
	pressed.connect(_on_button_pressed)

func _on_button_pressed():
	pass
