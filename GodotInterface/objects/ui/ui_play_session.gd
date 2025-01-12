extends Control
class_name UIPlaySession

@export var player_chosen_card_container : ChosenCardContainer
@export var other_chosen_card_container : ChosenCardContainer
@export var player_choice_button : CardChoiceButton
@export var player_hand_panel : CardsHandPanel

func _ready() -> void:
	player_choice_button.pressed.connect(_on_choice_button_pressed)

func _on_choice_button_pressed():
	if player_hand_panel.has_chosen_card():
		player_hand_panel.chosen_card_node.reparent(player_chosen_card_container)
		pass
	else:
		print("no card has been chosen!")
