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
	
	real_player.player_data = session_data.player_1_data
	ai_player.player_data = session_data.player_2_data
	
	HTTPHandler.session_status_returned.connect(_on_session_status_returned)
	HTTPHandler.round_finished.connect(_on_session_round_finished)
	HTTPHandler.session_finished.connect(_on_session_game_finished)
	
	initialize_session()

func initialize_session():
	# set player hand
	play_session_ui.set_up_player_hand(real_player.get_hand_cards())
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
	print("chosen")
	play_session_ui.update_other_player_status("Chosen")
	play_session_ui.update_other_player_choice(data)
	print("should've updated other player choice")


func _on_player_chose_card(card : CardData):
	# send http request
	
	HTTPHandler.play_card(session_data.session_id, real_player.player_data.player_name, card)
	
	start_ai_turn()

func _on_ai_chose_card(card : CardData):

	update_ai_status_chosen(card)
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
	print("player 1 cards ", data.player_1_data.parse_hand_resource(data.player_1_data.player_hand))
	print("player 2 cards ", data.player_2_data.parse_hand_resource(data.player_2_data.player_hand))
	
	# reset ui here
	play_session_ui.update_round_visuals(data)
	play_session_ui.other_chosen_card_container.get_child(0).reparent(play_session_ui.other_player_hand_panel)
	play_session_ui.set_up_player_hand(data.player_1_data.player_hand)
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
	
	# call session update
	
	HTTPHandler.get_session_state(session_data.session_id)
	
	# ui is reset whenever session update is called
	
	# 
	
func _on_session_game_finished():
	pass
	
