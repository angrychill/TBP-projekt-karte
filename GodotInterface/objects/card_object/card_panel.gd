extends PanelContainer
class_name CardPanel

var card_preview : PackedScene = preload("res://objects/card_object/card_panel_preview.tscn")

@export var card_data : CardData
@export var label_up : Label
@export var label_down : Label
@export var label_mid : Label

#func _init(data : CardData) -> void:
	#card_data = data

func _ready() -> void:
	pass
	
	label_down.text = str(card_data.value)
	label_up.text = str(card_data.value)
	label_mid.text = str(card_data.suit)

func _get_drag_data(at_position: Vector2) -> Variant:
	print("dragging!")
	var drag_data = card_data
	var origin_node = self
	generate_drag_preview(drag_data)
	return [drag_data, origin_node]

#func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	## if position isnt a dragreceiver container, return the card back
	#print("i can receive drop data")
	#return true
#
#func _drop_data(at_position: Vector2, data: Variant) -> void:
	#print("data")
	#pass

func generate_drag_preview(preview_data : CardData):
	var preview_panel : CardPanelPreview = card_preview.instantiate()
	preview_panel.card_data = preview_data
	preview_panel.global_position = get_global_mouse_position()
	preview_panel.drag_completed.connect(_on_preview_drag_completion)
	get_tree().current_scene.add_child(preview_panel)
	pass

func _on_preview_drag_completion(data):
	print("drag completed x2")
