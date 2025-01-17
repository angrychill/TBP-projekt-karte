extends Control

const ONE_SESSION = preload("res://objects/ui/one_session.tscn")

@export var create_new_session_button : Button
@export var see_previous_sessions_button : Button
@export var quit_game_button : Button
@export var rejoin_session_button : Button

@export var main_settings_container : Control
@export var new_session_container : NewSessionSettings
@export var past_sessions_container : Control

@export var rejoin_session_container : RejoinSessionSettings


@export var go_back_button_session : Button
@export var go_back_button_past : Button
@export var go_back_button_rejoin : Button

@export var sessions_container : Control

@export var rules_button : Button
@export var rules_container : Control
@export var rules_back : Button


func _ready() -> void:
	
	HTTPHandler.session_summary_retrieved.connect(_on_session_summary_retrieved)
	
	rejoin_session_button.pressed.connect(_on_rejoin_session_button_pressed)
	quit_game_button.pressed.connect(_on_quit_game_button_pressed)
	create_new_session_button.pressed.connect(_on_create_new_session_button_pressed)
	see_previous_sessions_button.pressed.connect(_on_view_past_sessions_button_pressed)
	go_back_button_session.pressed.connect(_on_go_back_pressed)
	go_back_button_past.pressed.connect(_on_go_back_pressed)
	new_session_container.start_new_session.connect(_on_new_session_requested)
	go_back_button_rejoin.pressed.connect(_on_go_back_pressed)
	rejoin_session_container.rejoin_session.connect(_on_session_rejoin_requested)
	rules_button.pressed.connect(_on_rules_button_pressed)
	rules_back.pressed.connect(_on_go_back_pressed)

func _on_session_rejoin_requested(id : int):
	get_parent().request_rejoin_session(id)

func _on_new_session_requested(id : int, player_name : String):
	get_parent().request_new_session(id, player_name)

func _on_quit_game_button_pressed():
	#HTTPHandler.close_connection()
	await get_tree().create_timer(1.0).timeout
	get_tree().quit()

func _on_create_new_session_button_pressed():
	main_settings_container.hide()
	new_session_container.show()

func _on_view_past_sessions_button_pressed():
	HTTPHandler.get_sessions_summary()
	main_settings_container.hide()
	past_sessions_container.show()

func _on_rejoin_session_button_pressed():
	main_settings_container.hide()
	rejoin_session_container.show()
	pass

func _on_rules_button_pressed():
	new_session_container.hide()
	past_sessions_container.hide()
	rejoin_session_container.hide()
	main_settings_container.hide()
	rules_container.show()

func _on_go_back_pressed():
	new_session_container.hide()
	past_sessions_container.hide()
	rejoin_session_container.hide()
	rules_container.hide()
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
	
