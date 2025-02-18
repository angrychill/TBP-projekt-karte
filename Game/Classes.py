from enum import Enum
from collections import deque
import ZODB
import persistent
from persistent.list import PersistentList
from persistent.mapping import PersistentMapping
import random
from BTrees import IOBTree

class CardValue(Enum):
    SEVEN = 7
    EIGHT = 8
    NINE = 9
    TEN = 10
    UNTERMANN = 11
    OBERMANN = 12
    KONIG = 13
    ACE = 100
    
class CardSuit(Enum):
    HEARTS = "Hearts"
    ACORNS = "Acorns"
    BELLS = "Bells"
    LEAVES = "Leaves"

suit_hierarchy = {
    CardSuit.HEARTS: [CardSuit.ACORNS],
    CardSuit.ACORNS: [CardSuit.LEAVES],
    CardSuit.LEAVES: [CardSuit.BELLS],
    CardSuit.BELLS: [CardSuit.HEARTS]
}


class Card(persistent.Persistent):
    
    def __init__(self, card_suit, card_value):
        self.card_value = card_value
        self.card_suit = card_suit
    
    def get_value(self) -> CardValue:
        return self.card_value
    
    def get_suit(self) -> CardSuit:
        return self.card_suit
    
    def parse_card(self):
        suit : CardSuit = self.card_suit
        value : CardValue = self.card_value
        return [suit.value , value.value]
        
    
class Deck(persistent.Persistent):
    
    def __init__(self):
        self.cards = PersistentList(self.generate_deck())
    
    def generate_deck(self) -> PersistentList:
        deck = [Card(suit, value) for suit in CardSuit for value in CardValue]
        random.shuffle(deck)
        return deck
    
    def draw_card(self) -> Card:
        ''' pops card from deck and returns card value '''
        if len(self.cards) > 0:
            drawn_card = self.cards.pop()
            self._p_changed = 1
            return drawn_card
        else:
            print("empty deck")
            return None

    def get_deck_size(self) -> int:
        return len(self.cards)

    
class Player(persistent.Persistent):
    def __init__(self, name):
        super().__init__()
        self.name = name
        self.score = 0
        self.cards = PersistentList()
        self.chosen_card : Card = None
    
    def play_card(self, selected_card : Card) -> Card:
        '''removes card from player hand and returns card object'''
        card_to_play = self.is_parsed_card_in_hand(selected_card)
        if self.cards and card_to_play:
            print("can play card!")
            played_card : Card = self.cards.pop(self.cards.index(card_to_play))
            return played_card
        else:
            print("cant play card!")

    def add_card_to_deck(self, card : Card):
        if len(self.cards) <= 4:
            self.cards.append(card)
        else:
            print("too many cards in hand")
        
    def get_player_score(self):
        return self.score
    
    def increase_player_score(self):
        self.score += 1
        self._p_changed = 1
    
    def clear_player_score(self):
        self.score = 0
        self._p_changed = 1
    
    def get_player_cards(self) -> int:
        num_of_valid_cards : int = 0
        for card in self.cards:
            if card != None:
                num_of_valid_cards += 1
        
        return num_of_valid_cards
      
    def is_parsed_card_in_hand(self, card_to_parse : Card) -> Card:
        ''' return card object if found from parsed key: value \n
        if none is found returns none'''
        if len(self.cards) > 0:
            card : Card
            for card in self.cards:
                if card.get_suit() == card_to_parse.get_suit() and card.get_value() == card_to_parse.get_value():
                    return card
            
            # if none found
            return None
    
    def set_chosen_card(self, card : Card):
        if card:
            self.chosen_card = card
            self._p_changed = 1
        else:
            print("cannot set card!")
    
    def clear_chosen_card(self):
        self.chosen_card = None
        self._p_changed = 1

    def has_chosen_card(self) -> bool:
        if self.chosen_card != None:
            return True
        else:
            return False
    
    def get_chosen_card(self) -> Card:
        if self.chosen_card != None:
            return self.chosen_card
        else:
            return None

class GameSession(persistent.Persistent):
    def __init__(self, session_id, player1_name, player2_name):
        super().__init__()
        self.session_id = session_id
        self.player1 = Player(player1_name)
        self.player2 = Player(player2_name)
        self.winner : Player = None
        self.deck : Deck = Deck()
        self.suit_hierarchy = suit_hierarchy
        self.finished = False

    def deal_cards(self):
        for i in range(0, 4, 1):
            card_to_deal_1 : Card = self.deck.draw_card()
            self.player1.add_card_to_deck(card_to_deal_1)
            
            card_to_deal_2 : Card = self.deck.draw_card()
            self.player2.add_card_to_deck(card_to_deal_2)
    
    def compare_suits(self, suit1 : CardSuit, suit2 : CardSuit) -> int:
        if suit2 in self.suit_hierarchy[suit1]:
            return 1 # suit 1 stronger
        if suit1 in self.suit_hierarchy[suit2]:
            return 2 # suit 2 stronger
        return 0 # equal strength
    
    def compare_cards(self, card1 : Card, card2 : Card) -> int:
        suit_comparison : int = self.compare_suits(card1.card_suit, card2.card_suit)
        
        # in case an ace is played by one player
        if card1.get_value() == CardValue.ACE or card2.get_value() == CardValue.ACE:
            
            # in case if ace is played by both players
            if card1.get_value() == CardValue.ACE and card2.get_value() == CardValue.ACE:
                return suit_comparison
           
            # if ace is played by only one player
            else:
                # return player who played ace
                if card1.get_value() == CardValue.ACE:
                    return 1
                else:
                    return 2

        # if no one played ace
        else:
            # standard case
            if suit_comparison != 0:
                return suit_comparison
            # if suits are equal return stronger value
            else:
                if card1.get_value().value == card2.get_value().value:
                    return 0
                else:
                    return 1 if card1.get_value().value > card2.get_value().value else 2

    
    def determine_round_winner(self, player1choice : Card, player2choice : Card):
        
        comp = self.compare_cards(player1choice, player2choice)
        
        # if comp returns 0, both players get a point for a tie
        return comp
    
    def determine_session_winner(self, player1 : Player, player2 : Player) -> str:
        if not self.finished:
            return None
        else:
            if player1.get_player_score() == player2.get_player_score():
                return "Tie"
            else:
                return player1.name if player1.get_player_score() > player2.get_player_score() else player2.name
    
    def check_if_both_players_chose_cards(self) -> bool:
        return self.player1.has_chosen_card() and self.player2.has_chosen_card()
    
    def deal_cards_end_turn(self, prev_round_winner : int):
        if self.deck:
            first_card_draw : int = prev_round_winner
            if prev_round_winner == 0:
                first_card_draw = random.randint(1, 2)
            
            if first_card_draw == 1:
                card1 = self.deck.draw_card()
                card2 = self.deck.draw_card()
                if card1 != None:
                    self.player1.add_card_to_deck(card1)
                if card2 != None:
                    self.player2.add_card_to_deck(card2)
            else:
                
                card1 = self.deck.draw_card()
                card2 = self.deck.draw_card()

                if card1 != None:
                    self.player2.add_card_to_deck(card1)
                if card2 != None:
                    self.player1.add_card_to_deck(card2)
        else:
            print("no more cards to deal!")
    
    def play_round(self, player_1_move : Card, player_2_move : Card) -> int:
        # round ends when both players played
        round_winner = self.determine_round_winner(player_1_move, player_2_move)
        self.player1.clear_chosen_card()
        self.player2.clear_chosen_card()
  
        if round_winner == 0:
            # just in case of tie
            # both players get points
            print("tie")
            self.player1.increase_player_score()
            self.player2.increase_player_score()
            return 0
        elif round_winner == 1:
            # player 1 gets point
            self.player1.increase_player_score()
            return 1
        else:
            # player 2 gets point
            self.player2.increase_player_score()
            return 2
    
    
    def play_session(self):
        if self.finished:
            self.winner = self.determine_session_winner(self.player1, self.player2)
            self._p_changed = 1

        
        if self.deck.get_deck_size() <= 0:
            if self.player1.get_player_cards() <= 0 or self.player2.get_player_cards() <= 0:
                self.finished = True
                self._p_changed = 1
    
    def end_session(self):
        if self.finished:
            self.winner = self.determine_session_winner(self.player1, self.player2)
            self._p_changed = 1    
    
    def get_session_winner_int(self) -> int:
        if self.finished:
            return self.winner
        else:
            print("round not yet finished")
            return None
    
    def get_session_winner_player(self) -> Player:
        if self.finished:
            if self.winner == 1:
                return self.player1
            elif self.winner == 2:
                return self.player2
            else:
                return 0
    
    def set_session_finished(self, finished_value : bool):
        self.finished = finished_value
        self._p_changed = 1
        
class GameRoot(persistent.Persistent):
    def __init__(self):
        super().__init__()
        self.sessions = IOBTree.IOBTree() # key: ID, value: gamesession
    
    def create_session(self, session_id : int, player_1_name, player_2_name) -> GameSession:
        if session_id in self.sessions:
            raise ValueError("Session ID already exists.")
        session = GameSession(session_id, player_1_name, player_2_name)
        print(self.sessions)
        self.sessions[session_id] = session

        return session
    
    def get_session(self, session_id) -> GameSession:
        if not self.sessions.get(session_id):
            return None
        else:
            return self.sessions[session_id]
    
    def delete_session(self, session_id: int):
        if session_id in self.sessions:
            del self.sessions[session_id]
    