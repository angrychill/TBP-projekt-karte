import ZODB.FileStorage
from flask import Flask, request, jsonify
from flask_cors import CORS
from ZODB import DB
from ZODB.FileStorage import FileStorage
from persistent import Persistent
from persistent.mapping import PersistentMapping
import transaction
from Classes import *
from flask import g
from BTrees import IOBTree

# flask
app = Flask(__name__)
CORS(app)

# ZODB
storage = ZODB.FileStorage.FileStorage('C:/Program Files/GitHub projects/TBP-projekt-karte/DB/test_6.fs')
db = ZODB.DB(storage)

connection = db.open()
root = connection.root()

game_root : GameRoot

if 'game_root' not in root:
    print("game root not found")
    root['game_root'] = GameRoot()
else:
    print("game root found")

game_root = root['game_root']

for key in game_root.sessions:
    print("a")
    print(key)



transaction.commit()

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
            return jsonify({"message": "Session already exists"}), 400
        session = game_root.create_session(session_id, player_1_name, player_2_name)
        session.deal_cards()
        game_root._p_changed = True 
        transaction.commit()
        
        return jsonify({
            "message": "Session created",
            "session_id": session_id})
    
    except ValueError as e:
        transaction.abort()
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
    
        
    session : GameSession = game_root.get_session(session_id)
    
    if not session:
        return jsonify({"error": "Session not found"}), 404

    played_card : Card
    session_player : Player
    
    if player == session.player1.name:
        session_player = session.player1
        played_card = session_player.play_card(card)
        session._p_changed = 1
        transaction.commit()
    elif player == session.player2.name:
        session_player = session.player2
        played_card = session_player.play_card(card)
        session._p_changed = 1
        transaction.commit()
    else:
        return jsonify({"error": "Player not found."}), 400
    
    if not played_card or played_card == None:
        transaction.commit()
        return jsonify({"error": f"Card not found in player {session_player.name} hand."}), 400
    else:
        session_player.set_chosen_card(played_card)
        session._p_changed = 1
        transaction.commit()
    
    # check whether both players played
    if session.check_if_both_players_chose_cards():
        session_round_winner = session.play_round(session.player1.get_chosen_card(), session.player2.get_chosen_card())
        session.deal_cards_end_turn(session_round_winner)
        session._p_changed = 1
        transaction.commit()
        
        # check if the session has ended
        if session.deck.get_deck_size() == 0 \
            and session.player1.get_player_cards() == 0 or session.player2.get_player_cards() == 0:
                session.set_session_finished(True)
                session.end_session()

                transaction.commit()

                
                print("session finished!")
                
                return jsonify({
                    "message": "Session finished",
                    "winner": session.winner,
                    "player_1_score": session.player1.get_player_score(),
                    "player_2_score": session.player2.get_player_score()
                })
        else:
            print("round finished")
      
            return jsonify({
                "message": "Round finished",
                "winner": session_round_winner,
                "player_1_score": session.player1.get_player_score(),
                "player_2_score": session.player2.get_player_score()
                
            })
    
    transaction.commit()
    return jsonify({"message": "Card played"}), 200

@app.route('/get_session_state', methods=['GET'])
def get_session_state():
    data = request.json
    session_id = data['session_id']
    
    session : GameSession = game_root.get_session(session_id)
    if not session:
        return jsonify({"error": "Session not found."}), 404
    
    session_winner = "None" if session.winner == None else session.winner
    
    state = {
        "player_1": {
            "name": session.player1.name,
            "score": session.player1.get_player_score(),
            "hand": [card.parse_card() for card in session.player1.cards if card]
        },
        
        "player_2": {
            "name": session.player2.name,
            "score": session.player2.get_player_score(),
            "hand": [card.parse_card() for card in session.player2.cards if card]
        },
        "message": "Session state retrieved",
        "deck_size": session.deck.get_deck_size(),
        "finished": session.finished,
        "session_id": session_id,
        "session_winner": session_winner
    }
    
    return jsonify(state), 200

@app.route('/rejoin_session', methods=['GET'])
def rejoin_unfinished_session():
    data = request.json
    session_id = data['session_id']
    session : GameSession = game_root.get_session(session_id)
    
    if not session or session == None:
        return jsonify({"message": "Session not found"}), 404
    
    if session.finished:
        return jsonify({"message": "Session not found"}), 400
    
    state = {
        "player_1": {
            "name": session.player1.name,
            "score": session.player1.get_player_score(),
            "hand": [card.parse_card() for card in session.player1.cards if card]
        },
        
        "player_2": {
            "name": session.player2.name,
            "score": session.player2.get_player_score(),
            "hand": [card.parse_card() for card in session.player2.cards if card]
        },
        "message": "Session rejoined",
        "deck_size": session.deck.get_deck_size(),
        "finished": session.finished,
        "session_id": session_id
    }
    
    return jsonify(state), 200


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
        return jsonify({"message": "Session successfully deleted"})
    
    except ValueError as e:
        return jsonify({"error": str(e)}), 400


@app.route('/get_all_sessions_summary', methods=['GET'])
def get_all_sessions_summary():
    try:
        sessions = game_root.sessions
        
        session_summaries = []
        
        for session_id, session in sessions.items():
            session_summary = {
                "session_id": session_id,
                "winner": session.winner,
                "finished": session.finished,
            }
            session_summaries.append(session_summary)
        
        response = {
            "message": "Retrieved session summaries",
            "sessions": session_summaries
        }
        
        print("num of sessions", len(session_summaries))
        
        return jsonify(response), 200
    
    
    except Exception as e:
        return jsonify({"message": "Error retrieving sessions", "error": str(e)}), 500


if __name__ == '__main__':
    app.run(debug=False)