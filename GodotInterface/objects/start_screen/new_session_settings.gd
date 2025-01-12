extends VBoxContainer
class_name NewSessionSettings

@export var start_session_button : Button
@export var player_1_name_input : LineEdit
@export var session_id_input : LineEdit

signal start_new_session(id : int, player_name : String)

func _ready() -> void:
	start_session_button.pressed.connect(_start_new_session_button_pressed)

func _start_new_session_button_pressed():
	if not session_id_input.text.is_valid_int():
		print("id isn't an integer!")
	else:
		var session_id = session_id_input.text.to_int()
		var player_1_name = player_1_name_input.text
		start_new_session.emit(session_id, player_1_name)
