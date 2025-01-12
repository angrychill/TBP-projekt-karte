extends VBoxContainer
class_name OneSession

var session_data : Array

@export var id_label : Label
@export var winner_label : Label
@export var session_finished_label : Label

#func _ready() -> void:
	#id_label.text = str(session_data[0])
	#winner_label.text = session_data[1]
	#session_finished_label.text = str(session_data[2])
