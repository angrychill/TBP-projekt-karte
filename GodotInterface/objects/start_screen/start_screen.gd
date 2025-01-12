extends Control

const ONE_SESSION = preload("res://objects/ui/one_session.tscn")

@export var create_new_session_button : Button
@export var see_previous_sessions_button : Button
@export var quit_game_button : Button

@export var main_settings_container : Control
@export var new_session_container : NewSessionSettings
@export var past_sessions_container : Control

@export var go_back_button_session : Button
@export var go_back_button_past : Button

@export var sessions_container : Control

func _ready() -> void:
	
	HTTPHandler.session_summary_retrieved.connect(_on_session_summary_retrieved)
	
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
	HTTPHandler.get_sessions_summary()
	main_settings_container.hide()
	


func _on_go_back_pressed():
	new_session_container.hide()
	past_sessions_container.hide()
	main_settings_container.show()

func _on_session_summary_retrieved(sessions : Array):
	
	for child in sessions_container.get_children():
		child.queue_free()
	
	
	for session in sessions:
		var new_session_block : OneSession = ONE_SESSION.instantiate()
		new_session_block.id_label.text = str(session["session_id"])
		new_session_block.winner_label.text = str(session["winner"])
		new_session_block.session_finished_label.text = str(session["finished"])
		sessions_container.add_child(new_session_block)
	
	past_sessions_container.show()
