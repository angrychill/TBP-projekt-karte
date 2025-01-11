from enum import Enum
from collections import deque
import ZODB
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
    
    def parse_card(self) -> {CardSuit, CardValue}:
        return [self.card_suit.value , self.card_value.value]
        
    
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
    
    def draw_card(self) -> Card:
        ''' pops card from deck and returns card value '''
        if len(self.cards) >= 0:
            print("not empty")
            drawn_card = self.cards.pop()
            self._p_changed = 1
            return drawn_card
        else:
            print("empty deck")
            return None
    
    def add_to_discard(self, card):
        if len(self.discard_pile) <= 32:
            self.discard_pile.append(card)
            self._p_changed = 1
        else:
            print("too many cards in discard deck!")
    
    def get_discard_size(self) -> int:
        return len(self.discard_pile)

    def get_deck_size(self) -> int:
        return len(self.cards)
  
    
    def deck_debug(self):
        card : Card
        if self.cards:
            for card in self.cards:
                print(card.card_suit, card.card_value)
        print("amount of cards in deck", len(self.cards) )
        
        drawn_card = self.draw_card()
        print("drawing card", drawn_card.parse_card())
        print("amount of cards in deck", len(self.cards) )
        print("adding to discard pile", drawn_card.parse_card())
        self.add_to_discard(drawn_card)
        print("amount of cards in normal deck", len(self.cards) )
        print("amount of cards in discard pile", len(self.discard_pile))
    
class Player(Persistent):
    def __init__(self, name):
        super().__init__()
        self.name = name
        self.score = 0
        self.cards = PersistentList()
        self.can_play : bool = False
        self.chosen_card : Card = None
    
   # card initialization handled at the start of game?
   
    def enable_turn(self):
        self.can_play = True
        self._p_changed = 1
    
    def disable_turn(self):
        self.can_play = False
        self._p_changed = 1
    
    def play_card(self, selected_card : Card) -> Card:
        '''removes card from player hand and returns card object'''
        card_to_play = self.is_parsed_card_in_hand(selected_card)
        if self.cards and card_to_play:
            print("can play card!")
            played_card : Card = self.cards.pop(self.cards.index(card_to_play))
            self._p_changed = 1
            return played_card
        else:
            print("cant play card!")

    def add_card_to_deck(self, card : Card):
        if len(self.cards) <= 4:
            self.cards.append(card)
            self._p_changed = 1
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
        return len(self.cards)
      
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


class GameSession(Persistent):
    def __init__(self, session_id, player1_name, player2_name):
        super().__init__()
        self.session_id = session_id
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
        
    
    def determine_round_winner(self, player1choice : Card, player2choice : Card):
        
        comp = self.compare_cards(player1choice, player2choice)
        
        # if comp returns 0, both players get a point for a tie
        # shouldn't happen but yknow
        return comp
    
    def determine_session_winner(self, player1 : Player, player2 : Player) -> int:
        if not self.finished:
            return None
        else:
            if player1.score == player2.score:
                return 0
            else:
                return 1 if player1.score > player2.score else 2
    
    def check_if_both_players_chose_cards(self) -> bool:
        return self.player1.chosen_card and self.player2.chosen_card
    
    def deal_cards_end_turn(self, prev_round_winner : int):
        if self.deck:
            first_card_draw : int = prev_round_winner
            if prev_round_winner == 0:
                first_card_draw = random.randint(1, 2)
            
            if first_card_draw == 1:
                card = self.deck.draw_card()
                self.player1.add_card_to_deck(card)
            else:
                card = self.deck.draw_card()
                self.player2.add_card_to_deck(card)
        else:
            print("no more cards to deal!")
    
    def play_round(self, player_1_move : Card, player_2_move : Card) -> int:
        # round ends when both players played
        round_winner = self.determine_round_winner(player_1_move, player_2_move)
        
        if round_winner == 0:
            # just in case of tie
            # both players get points
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

        pass
    
    def play_session(self):
        if self.finished:
            self.winner = self.determine_session_winner(self.player1, self.player2)
            self._p_changed = 1
            
        # self.deal_cards(self.player1, self.player2)
        
        if self.deck.get_deck_size() <= 0:
            if self.player1.get_player_cards <= 0 or self.player2.get_player_cards <= 0:
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
        
class GameRoot(Persistent):
    def __init__(self):
        super().__init__()
        self.sessions = PersistentMapping() # key: ID, value: gamesession
    
    def create_session(self, session_id : int, player_1_name, player_2_name) -> GameSession:
        session = GameSession(player_1_name, player_2_name)
        self.sessions[session_id] = session
        return session
    
    def get_session(self, session_id) -> GameSession:
        return self.sessions.get(session_id)