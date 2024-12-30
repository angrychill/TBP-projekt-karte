from enum import Enum

class CardValue(Enum):
    TWO = 2
    THREE = 3
    FOUR = 4
    FIVE = 5
    SIX = 6
    SEVEN = 7
    EIGHT = 8
    NINE = 9
    TEN = 10
    JACK = 11
    KING = 12
    QUEEN = 13
    ACE = 14
    JOKER = 15
    
class CardSuit(Enum):
    CLUBS = "Clubs"
    DIAMONDS = "Diamonds"
    HEARTS = "Hearts"
    SPADES = "Spades"

class Card:
    card_value : CardValue
    card_suit : CardSuit
    is_face_up : bool
    
    def __init__(self, card_value, card_suit, is_face_up):
        self.card_value = card_value
        self.card_suit = card_suit
        is_face_up = is_face_up
    
    def get_value(self) -> CardValue:
        return self.card_value
    
    def get_suit(self) -> CardSuit:
        return self.card_suit
    
    
    
        