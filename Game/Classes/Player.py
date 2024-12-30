# hand, discard
from . import Deck
from . import Card

class Player:
    hand : Deck
    
    def __init__(self, hand):
        self.hand = hand
        