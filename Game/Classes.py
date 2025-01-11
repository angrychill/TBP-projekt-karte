from enum import Enum
from collections import deque
from persistent import Persistent
from persistent.list import PersistentList
from persistent.mapping import PersistentMapping
import random

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
    CardSuit.HEARTS: [CardSuit.ACORNS, CardSuit.BELLS],
    CardSuit.ACORNS: [CardSuit.BELLS, CardSuit.LEAVES],
    CardSuit.BELLS: [CardSuit.LEAVES, CardSuit.HEARTS],
    CardSuit.LEAVES: [CardSuit.HEARTS, CardSuit.ACORNS]
}

class Card(Persistent):
    
    def __init__(self, card_suit, card_value):
        self.card_value = card_value
        self.card_suit = card_suit
    
    def get_value(self) -> CardValue:
        return self.card_value
    
    def get_suit(self) -> CardSuit:
        return self.card_suit
    
    def return_full_card_value(self) -> tuple[CardSuit, CardValue]:
        return [self.card_suit, self.card_value]
        
    
class Deck(Persistent):
    
    # it's a stack, so Last in, First out
    
    def __init__(self):
        self.cards = PersistentList(self.generate_deck())
        self.discard_pile = PersistentList()
        self.deck_debug()
    
    def generate_deck(self) -> PersistentList:
        deck = [Card(suit, value) for suit in CardSuit for value in CardValue]
        random.shuffle(deck)
        
        return deck
    
    def check_is_empty(self) -> bool:
        return len(self.cards) != 0
    
    def draw_card(self) -> Card:
        if self.check_is_empty == False:
            return self.cards.pop()
        else:
            return None
    
    def deck_debug(self):
        card : Card
        if self.cards:
            for card in self.cards:
                print(card.card_suit, card.card_value)
        print("amount of cards in deck", len(self.cards) )
    
class Player(Persistent):
    def __init__(self, name):
        super().__init__()
        self.name = name
        self.score = 0
        self.deck = PersistentList()
    
    def draw_card(self):
        if self.deck:
            return self.deck.pop(0)
        return None
    
    def add_card_to_deck(self, card):
        self.deck.append(card)
        
    def get_player_score(self):
        return self.score


class GameSession(Persistent):
    def __init__(self, player1_name, player2_name):
        super().__init__()
        self.player1 = Player(player1_name)
        self.player2 = Player(player2_name)
        self.winner : Player = None
        self.history = PersistentList()
        self.deck : Deck = self.generate_deck()
        self.suit_hierarchy = suit_hierarchy
        self.finished = False
    
    def generate_deck(self) -> PersistentList:
        deck = PersistentList([Card(suit, value) for suit in CardSuit for value in CardValue])
        random.shuffle(deck)
        return deck

    def deal_cards(self):
        pass
    
    def compare_suits(self, suit1 : CardSuit, suit2 : CardSuit) -> int:
        if suit2 in self.suit_hierarchy[suit1]:
            return 1 # suit 1 stronger
        if suit1 in self.suit_hierarchy[suit2]:
            return 2 # suit 2 stronger
        return 0 # equal strength
    
    def compare_cards(self, card1 : Card, card2 : Card) -> int:
        suit_comparison : int = self.compare_suits(card1.card_suit, card2.card_suit)
        
        # in case an ace is played by one player
        if card1.card_value == CardValue.ACE or card2.card_value == CardValue.ACE:
            
            # in case if ace is played by both players
            if card1.card_value == CardValue.ACE and card2.card_value == CardValue.ACE:
                return suit_comparison
           
            # if ace is played by only one player
            else:
                # return player who played ace
                if card1.card_value == CardValue.ACE:
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
                return 1 if card1.card_value > card2.card_value else 2
        
        return 0
    
    def play_round(self, player_moves):
        # round ends when dealer deck is empty
        if self.finished:
            return
 
        pass
    
    def determine_round_winner(self, player1choice : Card, player2choice : Card):
        
        comp = self.compare_cards(player1choice, player2choice)
        
        # if comp returns 0, both players get a point for a tie
        # shouldn't happen but yknow
        return comp
    
    def determine_session_winner(self, player1 : Player, player2 : Player):
        if not self.finished:
            return None
        else:
            if player1.score == player2.score:
                return 0
            else:
                return 1 if player1.score > player2.score else 2