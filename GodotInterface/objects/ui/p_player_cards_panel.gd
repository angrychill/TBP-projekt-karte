extends PanelContainer
class_name CardsHandPanel
const CARD_PANEL = preload("res://objects/card_object/card_panel.tscn")
@export var cards_parent : Control
var chosen_card_node : CardPanel
var chosen_card_data : CardData

func _ready() -> void:
	for child : CardPanel in cards_parent.get_children():
		child.card_clicked_on.connect(_on_card_clicked_on)

func _on_card_clicked_on(data : CardData, card : Node):
	chosen_card_data = data
	chosen_card_node = card
	
	for child : CardPanel in cards_parent.get_children():
		if child != chosen_card_node:
			child.reset_selection()
	pass

func remove_card(card : CardData):
	for child : CardPanel in cards_parent.get_children():
		if child.card_data == card:
			child.queue_free()

func add_card(data : CardData):
	var new_card : CardPanel = CARD_PANEL.instantiate()
	new_card.card_data = data
	new_card.card_clicked_on.connect(_on_card_clicked_on)
	cards_parent.add_child(new_card)

func has_chosen_card() -> bool:
	if chosen_card_node != null and chosen_card_data != null:
		return true
	else:
		return false

func clear_cards():
	for child : CardPanel in cards_parent.get_children():
		child.queue_free()
