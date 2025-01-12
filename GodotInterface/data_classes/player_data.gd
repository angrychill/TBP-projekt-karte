extends Resource
class_name PlayerData

@export var player_name : String
@export var player_hand : Array[CardData]
@export var player_score : int

func update_player_data(data : Dictionary):
	player_name = data["name"]
	player_score = data["score"]
	player_hand = parse_hand_data(data["hand"])

func parse_hand_data(data : Array) -> Array[CardData]:
	var hand : Array[CardData]
	for entry in data:
		var card : CardData = CardData.new()
		card.suit = card.string_to_suit(entry[0])
		card.value = entry[1]
		hand.append(card)
	return hand

func parse_hand_resource(array : Array[CardData]) -> Array:
	var parsed_array : Array
	for card in array:
		parsed_array.append([card.suit, card.value])
	return parsed_array
