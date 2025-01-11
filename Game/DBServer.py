from flask import Flask, request, jsonify
from flask_cors import CORS
from ZODB import DB
from ZODB.FileStorage import FileStorage
from persistent import Persistent
from persistent.mapping import PersistentMapping
import transaction
from Classes import *

# flask
app = Flask(__name__)
CORS(app)

# ZODB
storage = FileStorage('C:/Users/Iris/Documents/TBP-projekt-karte/DB/game_db.fs')
db = DB(storage)
connection = db.open()
root = connection.root()

if 'game_root' not in root:
    root['game_root'] = PersistentMapping()
    root['game_root']['sessions'] = GameRoot()
    transaction.commit()

game_root : GameRoot = root['game_root']['sessions']

# API
@app.route('/create_session', methods=['POST'])
def create_session():
    data = request.json
    session_id = data['session_id']
    player_1_name = data['player_1_name']
    player_2_name = data['player_2_name']
    
    print("player_1_name", player_1_name)
    print("player_2_name", player_2_name)
    
    try:

        if session_id in game_root.sessions:
            return jsonify({"error": "Session ID already exists"}), 400
        session = game_root.create_session(session_id, player_1_name, player_2_name)
        session.deal_cards()

        transaction.commit()
        
        return jsonify({"message": f"Session {session_id} created"})
    
    except ValueError as e:
        return jsonify({"error": str(e)}), 400
    
@app.route('/play_card', methods=['POST'])
def play_card():
    data = request.json
    session_id = data['session_id']
    player = data['player']
    card_data = data['card']
    card_suit = CardSuit(card_data['suit'])
    card_value = CardValue(card_data['value'])
    card : Card = Card(card_suit, card_value)
    
    if not card:
        return jsonify({"error": "Couldn't make card"}), 400
    else:
        print(card.parse_card())
        
    session : GameSession = game_root.get_session(session_id)
    
    if not session:
        return jsonify({"error": "Session not found"}), 404
    
    played_card : Card
    session_player : Player
    
    if player == session.player1.name:
        session_player = session.player1
        played_card = session_player.play_card(card)
    elif player == session.player2.name:
        session_player = session.player2
        played_card = session_player.play_card(card)
    else:
        return jsonify({"error": "Player not found."}), 400
    
    if not played_card:
        return jsonify({"error": "Card not found in player's hand."}), 400
    else:
        session_player.set_chosen_card(played_card)
        transaction.commit()
    
    # check whether both players played
    if session.check_if_both_players_chose_cards():
        session_round_winner = session.play_round(session.player1.chosen_card, session.player2.chosen_card)
        session.deal_cards_end_turn(session_round_winner)
        
        transaction.commit()
        
        # check if the session has ended
        if session.deck.get_deck_size() <= 0 \
            and session.player1.get_player_cards() <= 0 \
            and session.player2.get_player_cards() <= 0:
                session.finished = True
                session.end_session()
                transaction.commit()
                
                return jsonify({
                    "message": "Session finished",
                    "winner": session.get_session_winner_player().name,
                    "player_1_score": session.player1.get_player_score(),
                    "player_2_score": session.player2.get_player_score()
                })
    
    transaction.commit()
    return jsonify({"message": "Card played."}), 200

@app.route('/get_session_state', methods=['GET'])
def get_session_state():
    session_id = request.args.get('session_id')
    session : GameSession = game_root.get_session(session_id)
    if not session:
        return jsonify({"error": "Session not found."}), 404
    
    state = {
        "player_1": {
            "name": session.player1.name,
            "score": session.player1.get_player_score(),
            "hand": [card.parse_card() for card in session.player1.cards]
        },
        
        "player_2": {
            "name": session.player2.name,
            "score": session.player2.get_player_score(),
            "hand": [card.parse_card() for card in session.player2.cards]
        },
        
        "deck_size": session.deck.get_deck_size(),
        "finished": session.finished

    }
    
    return jsonify(state), 200

@app.route('/get_winner', methods=['GET'])
def get_winner():
    session_id = request.args.get('session_id')
    session : GameSession = game_root.get_session(session_id)
    if not session:
        return jsonify({"error": "Session not found."}), 404
    
    if not session.finished:
        return jsonify({"error": "Game is not finished yet."}), 400
    
    winner = session.get_session_winner_player()
    if winner == 0:
        return jsonify({"winner": 0, "score": None})
    else:
        return jsonify({"winner": winner.name, "score": winner.get_player_score()})

@app.route('/delete_session', methods=['POST'])
def delete_session():
    data = request.json
    session_id = data['session_id']

    try:

        if session_id in game_root.sessions:
           game_root.delete_session(session_id)
        else:
            return jsonify({"error": "Session ID doesn't exists"}), 400

        transaction.commit()
        return jsonify({"message": f"Session {session_id} deleted"})
    
    except ValueError as e:
        return jsonify({"error": str(e)}), 400

if __name__ == '__main__':
    app.run(debug=True)

