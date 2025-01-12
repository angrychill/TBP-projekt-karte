extends Node
@export var http_request : HTTPRequest

@export var server_url : String
var local_ip


func _ready() -> void:
	local_ip = IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),1)

	
	http_request.request_completed.connect(_on_request_completed)
	#request_node.request("https://api.github.com/repos/godotengine/godot/releases/latest")
	delete_session(2)
	await get_tree().create_timer(1.0).timeout
	create_session(2, "P1", "P2")
	await get_tree().create_timer(1.0).timeout
	get_session_state(2)
	await get_tree().create_timer(1.0).timeout
	var new_card : CardData = CardData.new()
	new_card.suit = CardData.CardSuit.HEARTS
	new_card.value =  CardData.CardValue.SEVEN
	var new_card2 : CardData = CardData.new()
	new_card2.suit = CardData.CardSuit.ACORNS
	new_card2.value =  CardData.CardValue.EIGHT
	play_card(2, "P1", new_card)
	get_session_state(2)
	await get_tree().create_timer(1.0).timeout
	play_card(2, "P2", new_card2)
	await get_tree().create_timer(1.0).timeout
	get_session_state(2)

func _on_request_completed(result, response_code, headers, body : PackedByteArray):
	var json = JSON.new()
	var message = json.parse(body.get_string_from_utf8())
	var data_received : Variant = json.data
	if response_code != 200:
		print("epic fail!", data_received)
	else:
		match (data_received["message"]):
			"Session winner returned":
				handle_session_winner_returned(data_received)
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


func create_session(id : int, player_1_name : String, player_2_name : String):
	var url : String = server_url + "/create_session"
	var body = {"session_id": id, "player_1_name": player_1_name, "player_2_name": player_2_name}
	var headers = ["Content-Type: application/json"]
	var json = JSON.stringify(body)
	http_request.request(url, headers, HTTPClient.METHOD_POST, json)

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

func handle_round_finish(data_received: Dictionary):
	print("round finished")
	pass

func handle_session_finish(data_received: Dictionary):
	print("session finished")
	pass

func handle_session_state_retrieval(data_received: Dictionary):
	print("session state")
	print(data_received)
	var new_player_1_data : PlayerData = PlayerData.new()
	var new_player_2_data : PlayerData = PlayerData.new()
	new_player_1_data.update_player_data(data_received["player_1"])
	new_player_2_data.update_player_data(data_received["player_2"])
	print(new_player_1_data)
	print(new_player_2_data)

func handle_card_played(data_received : Dictionary):
	print("card played")
	print("both players didnt play a card yet, requesting session state")
	

func handle_session_deleted(data_received : Dictionary):
	print("session deleted")

func handle_session_winner_returned(data_received: Dictionary):
	print("session winner returned")
