extends Resource
class_name CardData

enum CardValue {
	SEVEN = 7,
	EIGHT = 8,
	NINE = 9,
	TEN = 10,
	UNTERMANN = 11,
	OBERMANN = 12,
	KONIG = 13,
	ACE = 100
}

enum CardSuit {
	HEARTS = 1,
	ACORNS = 2,
	BELLS = 3,
	LEAVES = 4
}

@export var suit : CardSuit
@export var value : CardValue

func suit_to_string(suit : CardSuit) -> String:
	var key : String = CardSuit.find_key(suit)
	var string : String = key.capitalize()
	return string

func string_to_suit(string : String) -> CardSuit:
	var c_string = string.to_upper()
	var suit : CardSuit = CardSuit.get(c_string)
	return suit
