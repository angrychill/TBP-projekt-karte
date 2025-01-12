extends Resource
class_name SessionData

@export var session_id : int
@export var session_deck : Array[CardData]
@export var session_finished : bool = false
@export var winner : String
@export var player_1_data : PlayerData
@export var player_2_data : PlayerData

	#self.session_id = session_id
		#self.player1 = Player(player1_name)
		#self.player2 = Player(player2_name)
		#self.winner : Player = None
		#self.deck : Deck = Deck()
		#self.suit_hierarchy = suit_hierarchy
		#self.finished = False
