extends PanelContainer
class_name CardReceiver

@export var capacity : int = 1
@export var capacity_parent : Node

@export var can_receive : bool = true

@export var card_holding = null

const CARD_PANEL = preload("res://objects/card_object/card_panel.tscn")

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if can_receive:
		print(data)
		return true
	else:
		print("i cant receive")
		return false
	
func _drop_data(at_position: Vector2, data: Variant) -> void:
	print("received drop data ", data)
	add_card_to_self(data)
	if capacity_parent.get_child_count() >= capacity:
		can_receive = false
		print("cant receive!")
	else:
		can_receive = true
		print("can receive!")

func _get_drag_data(at_position: Vector2) -> Variant:
	print("dragging!")
	if card_holding != null:
		var drag_data = card_holding
		return drag_data
	else:
		return null

func add_card_to_self(data):
	var card_data = data[0]
	var origin_node = data[1]
	var card : CardPanel = CARD_PANEL.instantiate()
	card.card_data = card_data
	capacity_parent.add_child(card)
	card_holding = card
	origin_node.queue_free()
