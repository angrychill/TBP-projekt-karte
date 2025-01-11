extends Node
@export var http_request : HTTPRequest

@export var server_url : String
var local_ip

func _ready() -> void:
	local_ip = IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),1)

	
	http_request.request_completed.connect(_on_request_completed)
	#request_node.request("https://api.github.com/repos/godotengine/godot/releases/latest")
	create_session(randi_range(0, 100), "P1", "P2")

func _on_request_completed(result, response_code, headers, body):
	if result == http_request.RESULT_SUCCESS:
		print("success!")
		print("local server ip", server_url)
	else:
		print("epic fail!")
	pass	

func create_session(id : int, player_1_name : String, player_2_name : String):
	var url : String = server_url + "/create_session"
	var body = {"session_id": 1, "player_1_name": "Alice", "player_2_name": "Bob"}
	var headers = ["Content-Type: application/json"]
	var json = JSON.stringify(body)
	http_request.request(url, headers, HTTPClient.METHOD_POST, json)
