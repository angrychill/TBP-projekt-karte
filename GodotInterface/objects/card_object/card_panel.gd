extends PanelContainer
class_name CardPanel

signal card_clicked_on(card_data : CardData, card : Node)

@export var card_data : CardData
@export var label_up : Label
@export var label_down : Label
@export var is_face_down : bool = false
@export var sprite : TextureRect

#func _init(data : CardData) -> void:
	#card_data = data

func _ready() -> void:
	pass
	
	self.gui_input.connect(_on_input)
	
	label_down.text = CardUtility.labels[card_data.value]
	label_up.text = str(card_data.value)
	
	sprite.texture = CardUtility.sprites[card_data.suit]
	
	if is_face_down == true:
		for child in get_children():
			child.hide()
	else:
		for child in get_children():
			child.show()

func set_face_down_value():
	pass
	is_face_down = !is_face_down
	if is_face_down == false:
		pass
		# show everything
		for child in get_children():
			child.show()
	else:
		# hide everything
		for child in get_children():
			child.hide()

func _on_input(event : InputEvent):
	if event.is_action_pressed("click"):
		print("card clicked!")
		self.modulate = Color(1.5, 1.5, 1.5)
		card_clicked_on.emit(card_data, self)

func reset_selection():
	# print("reset selection")
	self.modulate = Color(1.0, 1.0, 1.0)
