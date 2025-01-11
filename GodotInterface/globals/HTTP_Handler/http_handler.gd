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
	play_card(2, "P1", "abcd")
	await get_tree().create_timer(1.0).timeout
	play_card(2, "P2", "abcd")

func _on_request_completed(result, response_code, headers, body):
	if result == 200:
		print("success!")
	else:
		print("epic fail!")
	pass	

func create_session(id : int, player_1_name : String, player_2_name : String):
	var url : String = server_url + "/create_session"
	var body = {"session_id": id, "player_1_name": "Alice", "player_2_name": "Bobberino"}
	var headers = ["Content-Type: application/json"]
	var json = JSON.stringify(body)
	http_request.request(url, headers, HTTPClient.METHOD_POST, json)

func play_card(id : int, player_1_name : String, card : String):
	var url : String = server_url + "/play_card"
	var body = {"session_id": id, "player": player_1_name, "card": {"suit": "Spades", "value": "Ace"}}
	var headers = ["Content-Type: application/json"]
	var json = JSON.stringify(body)
	http_request.request(url, headers, HTTPClient.METHOD_POST, json)

func delete_session(id : int):
	var url : String = server_url + "/delete_session"
	var body = {"session_id": id}
	var headers = ["Content-Type: application/json"]
	var json = JSON.stringify(body)
	http_request.request(url, headers, HTTPClient.METHOD_POST, json)
