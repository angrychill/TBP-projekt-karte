from . import Card
from collections import deque


class Deck:
    cards : list[Card.Card]
    
    # it's a stack, so Last in, First out
    
    def __init__(self, cards):
        cards = cards
    
    def add_card(self, card_to_add):
        self.cards.append(card_to_add)
    
    def add_cards(self, cards_to_add):
        self.cards.append(cards_to_add)
    
    def draw_card(self) -> Card:
        if not self.check_is_empty:
            self.cards.pop()
    
    def check_is_empty(self) -> bool:
        return self.cards.count != 0
    