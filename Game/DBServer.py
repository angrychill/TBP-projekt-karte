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

# flask
app = Flask(__name__)
CORS(app)

# ZODB
storage = ZODB.FileStorage.FileStorage('C:/Users/Iris/Documents/TBP-projekt-karte/DB/game_db2.fs')
db = ZODB.DB(storage)
connection = db.open()
root = connection.root()

if 'game_root' not in root:
    root['game_root'] = PersistentMapping()
if 'sessions' not in root['game_root']:
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
        
        return jsonify({
            "message": "Session created",
            "session_id": session_id})
    
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
        return jsonify({"error": f"Card not found in player {session_player.name} hand."}), 400
    else:
        session_player.set_chosen_card(played_card)
        transaction.commit()
    
    # check whether both players played
    if session.check_if_both_players_chose_cards():
        session_round_winner = session.play_round(session.player1.chosen_card, session.player2.chosen_card)
        session.deal_cards_end_turn(session_round_winner)
        
        transaction.commit()
        
        # check if the session has ended
        if len(session.deck.cards) == 0 \
            and (len(session.player1.cards) == 0 or len(session.player2.cards) == 0):
                session.finished = True
                session.end_session()
                transaction.commit()
                connection.close()
                print("session finished!")
                return jsonify({
                    "message": "Session finished",
                    "winner": session.winner,
                    "player_1_score": session.player1.score,
                    "player_2_score": session.player2.score
                })
        else:
            print("round finished")
            print("amount of ai cards", len(session.player2.cards))
            print("amount of player cards", len(session.player1.cards))
            return jsonify({
                "message": "Round finished",
                "winner": session_round_winner,
                "player_1_score": session.player1.score,
                "player_2_score": session.player2.score
                
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
            "score": session.player1.score,
            "hand": [card.parse_card() for card in session.player1.cards if card]
        },
        
        "player_2": {
            "name": session.player2.name,
            "score": session.player2.score,
            "hand": [card.parse_card() for card in session.player2.cards if card]
        },
        "message": "Session state retrieved",
        "deck_size": session.deck.get_deck_size(),
        "finished": session.finished,
        "session_id": session_id,
        "session_winner": session_winner
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
        return jsonify({
            "message": "Session winner returned",
            "winner": 0,
            "score": None})
    else:
        return jsonify({
            "message": "Session winner returned",
            "winner": winner.name,
            "score": winner.get_player_score()})

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

if __name__ == '__main__':
    app.run(debug=True)

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


@app.teardown_appcontext
def close_connection(exception=None):
    if connection:
        transaction.commit()
        connection.close()
        db.close()