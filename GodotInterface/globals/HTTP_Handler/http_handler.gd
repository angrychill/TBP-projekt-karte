extends Node
@export var http_request : HTTPRequest

@export var server_url : String
var local_ip

signal new_session_created(id : int)
signal session_status_returned(data : SessionData)
signal round_finished(round_winner : int, player_1_score : int, player_2_score : int)
signal session_summary_retrieved(sessions : Dictionary)
signal session_finished(session_winner : int, player_1_score : int, player_2_score : int)

func _ready() -> void:
	local_ip = IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),1)

	
	http_request.request_completed.connect(_on_request_completed)
	#request_node.request("https://api.github.com/repos/godotengine/godot/releases/latest")
	#delete_session(2)
	#await get_tree().create_timer(1.0).timeout
	#create_session(2, "P1", "P2")
	#await get_tree().create_timer(1.0).timeout
	#get_session_state(2)
	#await get_tree().create_timer(1.0).timeout
	#var new_card : CardData = CardData.new()
	#new_card.suit = CardData.CardSuit.HEARTS
	#new_card.value =  CardData.CardValue.SEVEN
	#var new_card2 : CardData = CardData.new()
	#new_card2.suit = CardData.CardSuit.ACORNS
	#new_card2.value =  CardData.CardValue.EIGHT
	#play_card(2, "P1", new_card)
	#get_session_state(2)
	#await get_tree().create_timer(1.0).timeout
	#play_card(2, "P2", new_card2)
	#await get_tree().create_timer(1.0).timeout
	#get_session_state(2)

func _on_request_completed(result, response_code, headers, body : PackedByteArray):
	var json = JSON.new()
	var message = json.parse(body.get_string_from_utf8())
	var data_received : Variant = json.data
	if response_code != 200:
		print("epic fail!", data_received)
	else:
		match (data_received["message"]):
			"Session state retrieved":
				handle_session_state_retrieval(data_received)
			"Round finished":
				handle_round_finish(data_received)
			"Session finished":
				handle_session_finish(data_received)
			"Card played":
				handle_card_played(data_received)
			"Session successfully deleted":
				handle_session_deleted(data_received)
			"Session created":
				handle_session_created(data_received)
			"Retrieved session summaries":
				handle_session_summaries(data_received)
			"Session rejoined":
				handle_session_rejoin(data_received)


func create_session(id : int, player_1_name : String, player_2_name : String):
	var url : String = server_url + "/create_session"
	var body = {"session_id": id, "player_1_name": player_1_name, "player_2_name": player_2_name}
	var headers = ["Content-Type: application/json"]
	var json = JSON.stringify(body)
	http_request.request(url, headers, HTTPClient.METHOD_POST, json)

func rejoin_session(id : int):
	var url : String = server_url + "/rejoin_session"
	var body = {"session_id": id}
	var headers = ["Content-Type: application/json"]
	var json = JSON.stringify(body)
	http_request.request(url, headers, HTTPClient.METHOD_GET, json)

func play_card(id : int, player_1_name : String, card : CardData):
	var url : String = server_url + "/play_card"
	var body = {"session_id": id, "player": player_1_name, "card": {"suit": card.suit_to_string(card.suit), "value": card.value}}
	var headers = ["Content-Type: application/json"]
	var json = JSON.stringify(body)
	http_request.request(url, headers, HTTPClient.METHOD_POST, json)

func get_session_state(id : int):
	
	var url : String = server_url + "/get_session_state"
	var body = {"session_id": id}
	var headers = ["Content-Type: application/json"]
	var json = JSON.stringify(body)
	http_request.request(url, headers, HTTPClient.METHOD_GET, json)

func delete_session(id : int):
	var url : String = server_url + "/delete_session"
	var body = {"session_id": id}
	var headers = ["Content-Type: application/json"]
	var json = JSON.stringify(body)
	http_request.request(url, headers, HTTPClient.METHOD_POST, json)

func close_connection():
	var url : String = server_url + "/close_connection"
	var headers = ["Content-Type: application/json"]
	print("closing connection")
	http_request.request(url, headers, HTTPClient.METHOD_POST, "")

func get_sessions_summary():
	var url : String = server_url + "/get_all_sessions_summary"
	var headers = ["Content-Type: application/json"]

	http_request.request(url, headers, HTTPClient.METHOD_GET, "")

# --- SESSION HANDLING ---

func handle_session_created(data_received : Dictionary):
	var session_id = data_received["session_id"]
	new_session_created.emit(session_id)
	pass

func handle_round_finish(data_received: Dictionary):
	print("round finished")
	var round_winner : int = data_received["winner"]
	var player_1_points : int = data_received["player_1_score"]
	var player_2_points : int = data_received["player_2_score"]
	round_finished.emit(round_winner, player_1_points, player_2_points)
	pass

func handle_session_rejoin(data_received : Dictionary):
	print("session rejoin")
	var new_player_1_data : PlayerData = PlayerData.new()
	var new_player_2_data : PlayerData = PlayerData.new()
	new_player_1_data.update_player_data(data_received["player_1"])
	new_player_2_data.update_player_data(data_received["player_2"])
	var session_id : int = data_received["session_id"]
	var remaining_deck_size : int = data_received["deck_size"]
	print(new_player_1_data)
	print(new_player_2_data)
	
	var new_session_data : SessionData = SessionData.new()
	new_session_data.player_1_data = new_player_1_data
	new_session_data.player_2_data = new_player_2_data
	new_session_data.session_id = session_id
	new_session_data.session_finished = data_received["finished"]
	
	new_session_data.winner = data_received["session_winner"]
	
	#print("player 1 cards in hand: ", new_player_1_data.player_hand.size())
	#print("player 2 cards in hand: ", new_player_2_data.player_hand.size())
	#print("player 1 cards ", new_player_1_data.parse_hand_resource(new_player_1_data.player_hand))
	#print("player 2 cards ", new_player_2_data.parse_hand_resource(new_player_2_data.player_hand))

	session_status_returned.emit(new_session_data)

func handle_session_finish(data_received: Dictionary):
	print("SESSION OVER")
	print("winner ", data_received["winner"])
	session_finished.emit(data_received["winner"], data_received["player_1_score"], data_received["player_2_score"])
	pass

func handle_session_state_retrieval(data_received: Dictionary):
	print("session state retrieved")
	var new_player_1_data : PlayerData = PlayerData.new()
	var new_player_2_data : PlayerData = PlayerData.new()
	new_player_1_data.update_player_data(data_received["player_1"])
	new_player_2_data.update_player_data(data_received["player_2"])
	var session_id : int = data_received["session_id"]
	var remaining_deck_size : int = data_received["deck_size"]
	print(new_player_1_data)
	print(new_player_2_data)
	
	var new_session_data : SessionData = SessionData.new()
	new_session_data.player_1_data = new_player_1_data
	new_session_data.player_2_data = new_player_2_data
	new_session_data.session_id = session_id
	new_session_data.session_finished = data_received["finished"]
	
	new_session_data.winner = data_received["session_winner"]
	
	#print("player 1 cards in hand: ", new_player_1_data.player_hand.size())
	#print("player 2 cards in hand: ", new_player_2_data.player_hand.size())
	#print("player 1 cards ", new_player_1_data.parse_hand_resource(new_player_1_data.player_hand))
	#print("player 2 cards ", new_player_2_data.parse_hand_resource(new_player_2_data.player_hand))

	session_status_returned.emit(new_session_data)

func handle_card_played(data_received : Dictionary):
	print("card played")
	print("both players didnt play a card yet, requesting session state")
	

func handle_session_deleted(data_received : Dictionary):
	print("session deleted")


func handle_session_summaries(data_received: Dictionary):
	print(data_received)
	var sessions : Array = data_received["sessions"]
	print("num of sessions ", sessions.size())
	session_summary_retrieved.emit(sessions)
	pass
