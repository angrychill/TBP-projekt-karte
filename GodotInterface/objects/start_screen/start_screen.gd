extends Control

@export var create_new_session_button : Button
@export var see_previous_sessions_button : Button
@export var quit_game_button : Button

@export var main_settings_container : Control
@export var new_session_container : NewSessionSettings
@export var past_sessions_container : Control

@export var go_back_button_session : Button
@export var go_back_button_past : Button

func _ready() -> void:
	quit_game_button.pressed.connect(_on_quit_game_button_pressed)
	create_new_session_button.pressed.connect(_on_create_new_session_button_pressed)
	see_previous_sessions_button.pressed.connect(_on_view_past_sessions_button_pressed)
	go_back_button_session.pressed.connect(_on_go_back_pressed)
	go_back_button_past.pressed.connect(_on_go_back_pressed)
	new_session_container.start_new_session.connect(_on_new_session_requested)

func _on_new_session_requested(id : int, player_name : String):
	get_parent().request_new_session(id, player_name)

func _on_quit_game_button_pressed():
	get_tree().quit()

func _on_create_new_session_button_pressed():
	main_settings_container.hide()
	new_session_container.show()

func _on_view_past_sessions_button_pressed():
	main_settings_container.hide()
	past_sessions_container.show()

func _on_go_back_pressed():
	new_session_container.hide()
	past_sessions_container.hide()
	main_settings_container.show()
