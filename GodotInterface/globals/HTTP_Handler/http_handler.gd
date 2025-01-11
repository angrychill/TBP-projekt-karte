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
	var new_card : CardData = CardData.new()
	new_card.suit = CardData.CardSuit.HEARTS
	new_card.value =  CardData.CardValue.SEVEN
	play_card(2, "P1", new_card)
	await get_tree().create_timer(1.0).timeout
	play_card(2, "P2", new_card)

func _on_request_completed(result, response_code, headers, body : PackedByteArray):
	var message = body.get_string_from_utf8()
	if response_code == 200:
		print("success!", message)
	else:
		print("epic fail!", message)
	pass	

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

func delete_session(id : int):
	var url : String = server_url + "/delete_session"
	var body = {"session_id": id}
	var headers = ["Content-Type: application/json"]
	var json = JSON.stringify(body)
	http_request.request(url, headers, HTTPClient.METHOD_POST, json)
