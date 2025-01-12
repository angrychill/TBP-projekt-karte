extends Node
class_name RealPlayer

signal choice_made(card : CardData)

@export var player_data : PlayerData

var chosen_card : CardData

func submit_card_choice():
	if chosen_card != null:
		choice_made.emit(chosen_card)
	pass

func get_hand_cards() -> Array[CardData]:
	return player_data.player_hand

func update_player_data(new_data : PlayerData):
	pass
