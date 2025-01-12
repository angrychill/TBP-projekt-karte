extends RealPlayer
class_name AIPlayer


func make_random_choice():
	var cards = player_data.player_hand
	var random_choice = cards.pick_random()
	print("made random choice!")
	choice_made.emit(random_choice)
	pass
