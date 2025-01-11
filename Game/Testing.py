from Classes import *

print(Deck())

player_1 = Player("player1")
print("player 1 cards", player_1.cards)
print("player 1 cards", len(player_1.cards))
card_1 = Card(CardSuit.ACORNS, CardValue.ACE)
card_2 = Card(CardSuit.HEARTS, CardValue.ACE)
player_1.add_card_to_deck(card_1)
print("player 1 cards", player_1.cards)
print("player 1 cards", len(player_1.cards))
played_card_1 = player_1.play_card(card_2)
print("player 1 cards", player_1.cards)
print("player 1 cards", len(player_1.cards))
played_card_2 = player_1.play_card(Card(CardSuit.HEARTS, CardValue.ACE))
print("player 1 cards", player_1.cards)
print("player 1 cards", len(player_1.cards))