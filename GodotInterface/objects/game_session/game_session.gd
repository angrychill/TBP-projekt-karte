extends Node
class_name GameSession

signal session_finished()

@export var session_data : SessionData

@export var ai_player : AIPlayer
@export var real_player : RealPlayer
@export var play_session_ui : UIPlaySession

func _ready() -> void:
	print("instantiating new game session")
	ai_player.choice_made.connect(_on_ai_chose_card)
	play_session_ui.player_chose_card.connect(_on_player_chose_card)
	play_session_ui.session_quit.connect(_on_session_quit)
	
	real_player.player_data = session_data.player_1_data
	ai_player.player_data = session_data.player_2_data
	
	HTTPHandler.session_status_returned.connect(_on_session_status_returned)
	HTTPHandler.round_finished.connect(_on_session_round_finished)
	HTTPHandler.session_finished.connect(_on_session_game_finished)
	
	initialize_session()

func initialize_session():
	# set player hand
	play_session_ui.set_up_player_hand(real_player.get_hand_cards())
	play_session_ui.set_up_ai_hand(ai_player.get_hand_cards())
	play_session_ui.player_label.text = real_player.player_data.player_name
	play_session_ui.other_player_score.text = str(ai_player.player_data.player_score)
	play_session_ui.player_score.text = str(real_player.player_data.player_score)
	pass

func _on_session_status_returned(data : SessionData):
	print("updating session!")
	
	ai_player.chosen_card = null
	real_player.chosen_card = null
	ai_player.player_data = data.player_2_data
	real_player.player_data = data.player_1_data
	
	#ai_player.update_player_data(data.player_2_data)
	#real_player.update_player_data(data.player_1_data)
	
	update_session(data)

func update_ai_status_waiting():
	print("choosing")
	play_session_ui.update_other_player_status("Choosing...")

func update_ai_status_chosen(data : CardData):
	play_session_ui.update_other_player_status("Chosen")
	play_session_ui.update_other_player_choice(data)
	

func _on_player_chose_card(card : CardData):
	# send http request
	
	HTTPHandler.play_card(session_data.session_id, real_player.player_data.player_name, card)
	
	start_ai_turn()

func _on_ai_chose_card(card : CardData):
	
	play_session_ui.update_session_status_waiting()
	
	update_ai_status_chosen(card)
	
	await get_tree().create_timer(1.0).timeout
	
	# send http request
	HTTPHandler.play_card(session_data.session_id, ai_player.player_data.player_name, card)
	
	pass

func start_ai_turn():
	print("starting ai turn!")
	update_ai_status_waiting()
	await get_tree().create_timer(1).timeout
	ai_player.make_random_choice()
	
func update_session(data : SessionData):
	print("session info data")
	
	# printing
	#print("player 1 cards ", data.player_1_data.parse_hand_resource(data.player_1_data.player_hand))
	#print("player 2 cards ", data.player_2_data.parse_hand_resource(data.player_2_data.player_hand))
	
	# reset ui here
	play_session_ui.update_round_visuals(data)
	play_session_ui.other_chosen_card_container.get_child(0).queue_free()
	play_session_ui.set_up_player_hand(data.player_1_data.player_hand)
	play_session_ui.set_up_ai_hand(data.player_2_data.player_hand)
	play_session_ui.player_chosen_card_container.get_child(0).queue_free()
	play_session_ui.enable_choice_button()
	play_session_ui.other_player_score.text = str(data.player_2_data.player_score)
	play_session_ui.player_score.text = str(data.player_1_data.player_score)
	
	# reset player data here
	#ai_player.chosen_card = null
	#real_player.chosen_card = null
	#ai_player.update_player_data(data.player_2_data)
	#real_player.update_player_data(data.player_1_data)
	

func _on_session_round_finished(round_winner : int, player_1_points : int, player_2_points : int):
	print("round winner ", round_winner)
	print("player 1 points ", player_1_points)
	print("player 2 points ", player_2_points)
	
	# some UI polish handling here
	# like maybe show_winner and stuff
	
	var round_win : String
	var tie : bool
	if round_winner == 0:
		tie = true
	else:
		tie = false
		if round_winner == 1:
			round_win = real_player.player_data.player_name
		else:
			round_win = ai_player.player_data.player_name
	play_session_ui.update_round_winner_label(round_win, tie)
	await get_tree().create_timer(1.0).timeout
	# call session update
	
	HTTPHandler.get_session_state(session_data.session_id)
	
	# ui is reset whenever session update is called
	
	# 
	
func _on_session_game_finished(winner : String, p1_score : int, p2_score : int):
	print("received session game finished!")
	var is_tie : bool
	if p1_score == p2_score:
		is_tie = true
	else:
		is_tie = false
	play_session_ui.update_session_winner_label(winner, is_tie)
	
	await get_tree().create_timer(2).timeout
	
	session_finished.emit()
	pass

func _on_session_quit():
	session_finished.emit()
