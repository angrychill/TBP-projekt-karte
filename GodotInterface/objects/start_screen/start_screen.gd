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

@export var sessions_status_label : Label
@export var sessions_list_label : Label
@export var start_session_status : Label


func _ready() -> void:
	
	HTTPHandler.session_summary_retrieved.connect(_on_session_summary_retrieved)
	HTTPHandler.session_found.connect(_on_session_found)
	HTTPHandler.create_new_session.connect(_on_create_new_session)
	
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
	
	main_settings_container.show()
	new_session_container.hide()
	past_sessions_container.hide()
	rejoin_session_container.hide()
	rules_container.hide()

func _on_create_new_session(session_created : bool):
	if session_created == false:
		start_session_status.text = "Can't create new session!"
	else:
		start_session_status.text = "Creating new session..."
	

func _on_session_found(found : bool):
	print("session found status retrieved")
	if found == false:
		sessions_status_label.text = "Session not found"
	else:
		sessions_status_label.text = "Session found!\n Rejoining..."


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
	
	if sessions.size() == 0:
		print("no sessions found")
		sessions_status_label.text = "0 sessions found"
	
	else:
		print("sessions found")
		var sessions_num : int= sessions.size()
		sessions_list_label.text = str(sessions_num) + " sessions found"
		for session in sessions:
			var new_session_block : OneSession = ONE_SESSION.instantiate()
			new_session_block.id_label.text = str(int(session["session_id"]))
			if session["winner"] == null:
				new_session_block.winner_label.text = "None"
			else:
				new_session_block.winner_label.text = str(session["winner"])
			new_session_block.session_finished_label.text = str(session["finished"])
			sessions_container.add_child(new_session_block)
	
