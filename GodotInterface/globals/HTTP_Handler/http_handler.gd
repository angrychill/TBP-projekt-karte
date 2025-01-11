extends Node
@export var request_node : HTTPRequest

@export var server_url : String
var local_ip

func _ready() -> void:
	local_ip = IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),1)
	server_url = local_ip
	
	request_node.request_completed.connect(_on_request_completed)
	#request_node.request("https://api.github.com/repos/godotengine/godot/releases/latest")
	var dummy_data = ["dummy", "dummy2"]
	send_data(dummy_data)
func _on_request_completed(result, response_code, headers, body):
	if result == request_node.RESULT_SUCCESS:
		print("success!")
		print("local server ip", server_url)
	else:
		print("epic fail!")
	pass	

func send_data(data_to_parse : Array):
	var json = JSON.stringify(data_to_parse)
	var headers = ["Content-Type: application/json"]
	request_node.request(server_url, headers, HTTPClient.METHOD_POST, json)
