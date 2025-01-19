extends Control
class_name UIPlaySession
const CARD_PANEL = preload("res://objects/card_object/card_panel.tscn")
@export var player_chosen_card_container : ChosenCardContainer
@export var other_chosen_card_container : ChosenCardContainer
@export var player_choice_button : Button
@export var player_hand_panel : CardsHandPanel
@export var other_player_choice_status : Label
@export var other_player_score : Label
@export var other_player_hand_panel : Control
@export var player_score : Label
@export var player_label : Label
@export var vs_label : Label

@export var quit_session_button : Button

signal player_chose_card(data : CardData)
signal session_quit()

var player_chosen_card_data : CardData

func _ready() -> void:
	player_choice_button.pressed.connect(_on_choice_button_pressed)
	quit_session_button.pressed.connect(_on_quit_session_pressed)

func _on_quit_session_pressed():
	session_quit.emit()

func _on_choice_button_pressed():
	if player_hand_panel.has_chosen_card():
		player_hand_panel.chosen_card_node.outline.visible = false
		player_hand_panel.chosen_card_node.reparent(player_chosen_card_container)
		player_chosen_card_container.modulate = Color(1.0, 1.0, 1.0)
		player_chosen_card_data = player_hand_panel.chosen_card_data
		disable_choice_button()
		print("player chose card!")
		player_chose_card.emit(player_chosen_card_data)
		pass
	else:
		print("no card has been chosen!")

func update_other_player_choice(data : CardData):
	print("updating other player choice!")
	var new_card : CardPanel = CARD_PANEL.instantiate()
	new_card.card_data = data
	other_player_hand_panel.get_child(0).queue_free()
	other_chosen_card_container.add_child(new_card)
	

func disable_choice_button():
	player_choice_button.disabled = true

func enable_choice_button():
	player_choice_button.disabled = false

func update_round_visuals(data : SessionData):
	print("updating round visuals")
	other_player_choice_status.text = "Choosing..."
	player_chosen_card_data = null
	#player_chosen_card_container.get_child(0).queue_free()
	set_up_player_hand(data.player_1_data.player_hand)
	vs_label.text = "vs"
	

func update_other_player_status(text : String):
	other_player_choice_status.text = text

func update_other_player_score(score : int):
	other_player_score.text = str(score)

func set_up_player_hand(cards : Array[CardData]):
	player_hand_panel.clear_cards()
	for card : CardData in cards:
		player_hand_panel.add_card(card)
	pass

func set_up_ai_hand(cards : Array[CardData]):
	for child in other_player_hand_panel.get_children():
		child.queue_free()

	
	for card : CardData in cards:
		var new_card : CardPanel = CARD_PANEL.instantiate()
		new_card.card_data = card
		other_player_hand_panel.add_child(new_card)
	pass

func update_round_winner_label(winner : String, is_tie : bool):
	if is_tie == false:
		vs_label.text = winner + " stronger!"
	else:
		vs_label.text = winner + "Tie!"
	pass

func update_session_winner_label(winner : String, is_tie : bool):
	if is_tie == false:
		vs_label.text = winner + " WON!"
	else:
		vs_label.text = "WINNER TIED!"
	pass

func update_session_status_waiting():
	vs_label.text = "Comparing..."
