extends Node
class_name GameHandler

var session_in_progress : bool = false

@export var scenes : Array[PackedScene]

# each session handles its own requests
# except when just getting started

func _ready() -> void:
	HTTPHandler.new_session_created.connect(_on_new_session_created)
	HTTPHandler.session_status_returned.connect(_on_session_status_returned)

func request_new_session(id : int, player_name : String):
	HTTPHandler.create_session(id, player_name, "AI")

func switch_to_game_session():
	get_child(0).queue_free()
	add_child(scenes[1].instantiate())

func switch_to_main_menu():
	get_child(0).queue_free()
	add_child(scenes[0].instantiate())

func _on_new_session_created(session_id : int):
	HTTPHandler.get_session_state(session_id)

func _on_session_status_returned(data : SessionData):
	if session_in_progress == true:
		print("session already in pogress, doing nothing")
	else:
		session_in_progress = true
		var new_session : GameSession = scenes[1].instantiate()
		new_session.session_data = data
		new_session.session_finished.connect(_on_session_finished)
		get_child(0).queue_free()
		add_child(new_session)

func _on_session_finished():
	print("sesh finished")
	session_in_progress = false
	switch_to_main_menu()
	pass
