extends VBoxContainer
class_name RejoinSessionSettings

@export var rejoin_session_button : Button
@export var session_id_input : LineEdit

signal rejoin_session(id : int)

func _ready() -> void:
	rejoin_session_button.pressed.connect(_rejoin_session_button_pressed)

func _rejoin_session_button_pressed():
	if not session_id_input.text.is_valid_int():
		print("id isn't an integer!")
	else:
		var session_id = session_id_input.text.to_int()
		rejoin_session.emit(session_id)
