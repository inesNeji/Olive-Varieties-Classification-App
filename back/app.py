import base64
import hashlib

from typing import Counter
from datetime import datetime, timedelta, timezone
import uuid
from itsdangerous import URLSafeTimedSerializer
from flask import Flask, request, jsonify, send_file
import pymongo
import tensorflow as tf
from tensorflow.keras.models import load_model  # type: ignore
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input  # type: ignore
from pymongo import MongoClient
from pymongo.errors import DuplicateKeyError
from datetime import datetime
import numpy as np
import cv2
import os
import smtplib
import random
import string
from email.mime.text import MIMEText
from dotenv import load_dotenv
from google.oauth2 import id_token
from google.auth.transport.requests import Request
import firebase_admin
from firebase_admin import credentials, auth
from flask import session, request, jsonify
from flask import Flask, request, jsonify
from werkzeug.utils import secure_filename
from io import BytesIO
from bson import ObjectId
import imghdr
load_dotenv()

MONGO_URI = os.getenv("MONGO_URI")
app = Flask(__name__)
app.secret_key = os.getenv("FLASK_SECRET_KEY")


cred = credentials.Certificate(r'C:\Users\medom\olive_leaf_analyzer\back\olive-leaf-analyzer-3c5b0-firebase-adminsdk-fbsvc-11098d8c0c.json')
firebase_admin.initialize_app(cred)


client = MongoClient(MONGO_URI)
db = client["leafscan"]
users_collection = db["users"]
historique_collection = db["historique"]
users_collection.create_index("email", unique=True)


MODEL_PATH = 'leaf_classification_model_transfer_learning.h5'
model = load_model(MODEL_PATH)
class_names = ['Chemlali_Sfaxi', 'Meski', 'Zarrazi']
IMG_SIZE = 224
model2 = load_model('olive_leaf_precheck_model.h5')



def segment_leaf(image):
    gray = cv2.cvtColor(image, cv2.COLOR_RGB2GRAY)
    blurred = cv2.GaussianBlur(gray, (5, 5), 0)
    edges = cv2.Canny(blurred, 50, 150)
    contours, _ = cv2.findContours(edges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    mask = np.zeros_like(gray)
    cv2.drawContours(mask, contours, -1, (255), thickness=cv2.FILLED)
    segmented = cv2.bitwise_and(image, image, mask=mask)
    return segmented

def preprocess_image(image_bytes):
    np_arr = np.frombuffer(image_bytes, np.uint8)
    image_bgr = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)
    image_rgb = cv2.cvtColor(image_bgr, cv2.COLOR_BGR2RGB)
    image_resized = cv2.resize(image_rgb, (IMG_SIZE, IMG_SIZE))
    image_segmented = segment_leaf(image_resized)
    image_normalized = image_segmented.astype(np.float32) / 255.0
    image_batch = np.expand_dims(image_normalized, axis=0)
    return image_batch

def generate_reset_code(length=8):
    return ''.join(random.choices(string.ascii_uppercase + string.digits, k=length))

def send_verification_code_email(name, email, code):
    sender_email = "scanleafapp@gmail.com"
    app_password = "vogqbrkfbfeazczn"

    subject = "Code de vérification pour réinitialiser votre mot de passe"
    body = f"""
    Bonjour {name},

    Voici votre code de vérification pour réinitialiser votre mot de passe : {code}

    Ce code expirera dans quelques minutes. Si vous n'avez pas demandé cette réinitialisation, ignorez simplement cet e-mail.

    Cordialement,
    L'équipe leafScan
    """

    msg = MIMEText(body)
    msg["Subject"] = subject
    msg["From"] = sender_email
    msg["To"] = email

    try:
        with smtplib.SMTP_SSL("smtp.gmail.com", 465) as server:
            server.login(sender_email, app_password)
            server.sendmail(sender_email, email, msg.as_string())
    except Exception as e:
        print(f"Erreur lors de l'envoi de l'email: {e}")
        raise Exception("Échec de l’envoi de l’e-mail")

def send_password_changed_confirmation(name, email):
    sender_email = "scanleafapp@gmail.com"
    app_password = "vogqbrkfbfeazczn"

    subject = "Confirmation de réinitialisation de mot de passe"
    body = f"""
    Bonjour {name},

    Votre mot de passe a été réinitialisé avec succès.

    Si vous n'êtes pas à l'origine de cette action, veuillez contacter notre support immédiatement.

    Cordialement,
    L'équipe leafScan
    """

    msg = MIMEText(body)
    msg["Subject"] = subject
    msg["From"] = sender_email
    msg["To"] = email

    try:
        with smtplib.SMTP_SSL("smtp.gmail.com", 465) as server:
            server.login(sender_email, app_password)
            server.sendmail(sender_email, email, msg.as_string())
    except Exception as e:
        print(f"Erreur lors de l'envoi de l'email: {e}")
        raise Exception("Échec de l’envoi de l’e-mail")


# --- Routes ---
@app.route('/predict', methods=['POST'])
def predict():
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400

    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No file selected'}), 400

    try:
        image = preprocess_image(file.read())
        predictions = model.predict(image)
        predicted_class = class_names[np.argmax(predictions[0])]
        confidence = float(np.max(predictions[0]))

        return jsonify({'class': predicted_class, 'confidence': confidence})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/signup', methods=['POST'])
def signup():
    data = request.json
    name = data.get('name')
    email = data.get('email')
    password = data.get('password')

    if not all([name, email, password]):
        return jsonify({'error': 'Veuillez remplir tous les champs'}), 400

    try:
        users_collection.insert_one({
            'name': name,
            'email': email,
            'password': password
        })
        return jsonify({'message': 'Compte créé avec succès'}), 201
    except DuplicateKeyError:
        return jsonify({'error': 'Un compte avec cet email existe déjà'}), 400
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'error': 'Erreur lors de la création du compte'}), 500

@app.route('/login', methods=['POST'])
def login():
    data = request.json
    email = data.get('email')
    password = data.get('password')

    if not all([email, password]):
        return jsonify({'error': 'Veuillez remplir tous les champs'}), 400

    user = users_collection.find_one({'email': email})
    if not user or user['password'] != password:
        return jsonify({'error': 'Email ou mot de passe incorrect'}), 400

    return jsonify({'message': 'Connexion réussie'}), 200

@app.route('/forgot-password', methods=['POST'])
def request_password_reset():
    data = request.json
    email = data.get('email')

    if not email:
        return jsonify({'error': 'Email requis'}), 400

    user = users_collection.find_one({'email': email})
    if not user:
        return jsonify({'error': 'Aucun utilisateur trouvé avec cet e-mail'}), 404

    code = generate_reset_code()
    users_collection.update_one({'email': email}, {'$set': {'reset_code': code}})

    try:
        send_verification_code_email(user['name'], email, code)
    except Exception:
        return jsonify({'error': "Erreur lors de l'envoi de l'email"}), 500

    return jsonify({'message': 'Un code a été envoyé à votre email.'}), 200

@app.route('/verify-code', methods=['POST'])
def verify_code():
    data = request.get_json()
    code = data.get('code')

    if not code:
        return jsonify({'error': 'Code requis'}), 400

    user = users_collection.find_one({'reset_code': code})
    if not user:
        return jsonify({'error': 'Code invalide'}), 400

    return jsonify({'message': 'Code vérifié', 'token': user['email']}), 200

@app.route('/change-password', methods=['POST'])
def reset_password():
    data = request.json
    token = data.get('token') 
    new_password = data.get('password')

    if not token or not new_password:
        return jsonify({'error': 'Paramètres manquants'}), 400

    user = users_collection.find_one({'email': token})
    if not user:
        return jsonify({'error': 'Utilisateur introuvable'}), 404

    users_collection.update_one({'email': token}, {'$set': {'password': new_password}, '$unset': {'reset_code': ""}})

    try:
        send_password_changed_confirmation(user['name'], token)
    except Exception:
        return jsonify({'error': "Erreur lors de l'envoi de l'e-mail de confirmation"}), 500

    return jsonify({'message': 'Mot de passe réinitialisé avec succès'}), 200


@app.route('/google-signin', methods=['POST'])
def google_signin():
    data = request.json
    google_token = data.get('token')  

    if not google_token:
        return jsonify({'error': 'Token requis'}), 400

    try:
       
        idinfo = id_token.verify_oauth2_token(google_token, Request())
        print(f"Token verified: {idinfo}")  

       
        email = idinfo.get('email')

        
        user = users_collection.find_one({'email': email})

       
        if not user:
           
            users_collection.insert_one({'email': email, 'name': idinfo.get('name'), 'password': None})

        return jsonify({'message': 'Google Sign-In successful', 'email': email}), 200
    except ValueError as e:
        print(f"Error verifying token: {e}")  
        return jsonify({'error': 'Token invalide'}), 400
        
import base64 

@app.route('/user', methods=['GET'])
def get_user():
    email = request.args.get('email')
    if not email:
        return jsonify({'error': 'Email is required'}), 400

    print(f"Fetching user with email: {email}") 

    user = users_collection.find_one({'email': email})
    if not user:
        print(f"User with email {email} not found.")  
        return jsonify({'error': 'User not found'}), 404

    # Get user fields
    user_email = user.get('email')
    user_name = user.get('name')
    user_picture = user.get('profile_picture')

    # Encode the picture if it exists
    picture_base64 = base64.b64encode(user_picture).decode('utf-8') if user_picture else None

    return jsonify({
        'email': user_email,
        'name': user_name,
        'picture': picture_base64  # added picture here
    })




@app.route('/modifypass', methods=['POST'])
def modify_password():
    data = request.json
    email = data.get('email')  
    old_password = data.get('old_password')
    new_password = data.get('new_password')
    confirm_password = data.get('confirm_password')

    if not all([email, new_password, confirm_password]):
        return jsonify({'error': 'Tous les champs sont requis'}), 400

    if new_password != confirm_password:
        return jsonify({'error': 'Les mots de passe ne correspondent pas'}), 400

    user = users_collection.find_one({'email': email})
    if not user:
        return jsonify({'error': 'Utilisateur introuvable'}), 404

    if user.get('password'):
        if not old_password:
            return jsonify({'error': 'Veuillez fournir votre ancien mot de passe'}), 400
        if user['password'] != old_password:
            return jsonify({'error': 'Ancien mot de passe incorrect'}), 400
    else:
        if old_password:
            return jsonify({'error': 'Vous n\'avez pas de mot de passe à modifier'}), 400

    users_collection.update_one({'email': email}, {'$set': {'password': new_password}})
    send_password_changed_confirmation(user['name'], email)

    return jsonify({'message': 'Mot de passe modifié avec succès'}), 200
@app.route('/save-result', methods=['POST'])
def save_result():
    import datetime
    email = request.form.get('email')
    result = request.form.get('result')
    confidence = request.form.get('confidence')
    image = request.files.get('image')

    if not all([email, result, confidence, image]):
        return jsonify({'status': 'error', 'message': 'Missing fields'}), 400

 
    image_blob = image.read()

    historique_entry = {
        'email': email,
        'result': result,
        'confidence': confidence,
        'image_blob': image_blob,  
        'filename': secure_filename(image.filename),
        'timestamp': datetime.datetime.now()
    }
    

    historique_collection.insert_one(historique_entry)

    return jsonify({'status': 'success', 'message': 'Result saved with image as blob'})



@app.route('/get-historique', methods=['GET'])
def get_historique():
    email = request.args.get('email')

    if not email:
        return jsonify({'status': 'error', 'message': 'Email parameter is required'}), 400

    email = email.strip()
    print(f"Looking for email: {email}")

    historique_entries = list(historique_collection.find({'email': email}))
    print(f"Fetched entries: {historique_entries}")

    if not historique_entries:
        return jsonify({'status': 'error', 'message': 'No data found for the provided email'}), 404

    result_data = []

    for entry in historique_entries:
        image_blob = entry['image_blob']
        file_extension = entry['filename'].split('.')[-1].lower()

        result_data.append({
            '_id': str(entry['_id']),  # Add the _id so frontend can delete precisely
            'email': entry['email'],
            'result': entry['result'],
            'confidence': entry['confidence'],
            'image_filename': entry['filename'],
            'timestamp': entry['timestamp'].isoformat(),
            'file_extension': file_extension
        })

    return jsonify({'status': 'success', 'data': result_data}), 200



@app.route('/get-image/<filename>', methods=['GET'])
def get_image(filename):
    entry = historique_collection.find_one({'filename': filename})
    if not entry:
        return jsonify({'status': 'error', 'message': 'Image not found'}), 404

    image_blob = entry['image_blob']
    image_stream = BytesIO(image_blob)

    if filename.lower().endswith('.jpg') or filename.lower().endswith('.jpeg'):
        mimetype = 'image/jpeg'
    elif filename.lower().endswith('.png'):
        mimetype = 'image/png'
    else:
        mimetype = 'application/octet-stream'

    return send_file(image_stream, mimetype=mimetype)
@app.route('/delete-historique', methods=['POST'])
def delete_historique():
    entry_id = request.json.get('_id')  

    if not entry_id:
        return jsonify({'status': 'error', 'message': 'Missing _id'}), 400

    try:
        result = historique_collection.delete_one({'_id': ObjectId(entry_id)})
    except Exception as e:
        return jsonify({'status': 'error', 'message': f'Invalid _id: {str(e)}'}), 400

    if result.deleted_count == 0:
        return jsonify({'status': 'error', 'message': 'No matching entry found'}), 404

    return jsonify({'status': 'success', 'message': 'Historique entry deleted'}), 200

@app.route('/dashboard', methods=['GET'])
def dashboard():
    email = request.args.get('email')
    if not email:
        return jsonify({'error': 'Email parameter is missing'}), 400

    email = email.strip()

    print("Email received:", email)

    historique_entries = list(historique_collection.find({'email': email}))
    print("Historique entries found:", len(historique_entries))

    if not historique_entries:
        return jsonify({
            "last_activity": None,
            "most_frequent_variety": None,
            "precision_per_variety": {},
            "total_analyses": 0,
            "varieties_count": 0,
            "variety_distribution": {},
            "weekly_activity": {}
        })

    # Extract fields
    varieties = []
    precisions = {}
    timestamps = []

    for entry in historique_entries:
        variety = entry.get('result')
        confidence = entry.get('confidence', '0%').replace('%', '')
        timestamp = entry.get('timestamp')

        if variety:
            varieties.append(variety)
            if variety not in precisions:
                precisions[variety] = []
            try:
                precisions[variety].append(float(confidence))
            except ValueError:
                pass

        if timestamp:
            timestamps.append(timestamp)

    # Process
    total_analyses = len(historique_entries)
    varieties_count = len(set(varieties))

    # Most frequent variety
    variety_counter = Counter(varieties)
    most_frequent_variety = variety_counter.most_common(1)[0][0] if variety_counter else None

    # Precision per variety
    precision_per_variety = {
        variety: round(sum(scores) / len(scores), 2)
        for variety, scores in precisions.items()
    }

    # Variety distribution
    variety_distribution = dict(variety_counter)

    # Last activity
    last_activity = max(timestamps) if timestamps else None

    # Weekly activity
    one_week_ago = datetime.now(timezone.utc) - timedelta(days=7)
    weekly_activity = {}

    for ts in timestamps:
        # Ensure that ts is timezone-aware
        if ts.tzinfo is None:
            ts = ts.replace(tzinfo=timezone.utc)  # Convert to UTC if naive
        
        if ts >= one_week_ago:
            day = ts.strftime('%Y-%m-%d')
            weekly_activity[day] = weekly_activity.get(day, 0) + 1

    # Return final data
    return jsonify({
        "last_activity": last_activity.isoformat() if last_activity else None,
        "most_frequent_variety": most_frequent_variety,
        "precision_per_variety": precision_per_variety,
        "total_analyses": total_analyses,
        "varieties_count": varieties_count,
        "variety_distribution": variety_distribution,
        "weekly_activity": weekly_activity
    })

@app.route('/upload-profile-picture', methods=['POST'])

def upload_profile_picture():
    email = request.form.get('email')
    picture = request.files.get('picture')

    if not email:
        return jsonify({'error': 'Missing email'}), 400

    if not picture:
        return jsonify({'error': 'Missing picture'}), 400
    


    # Read image bytes
    image_bytes = picture.read()

    # Update user's profile_picture field
    result = users_collection.update_one(
        {'email': email},
        {'$set': {'profile_picture': image_bytes}}
    )

    if result.modified_count == 1:
        return jsonify({'message': 'Profile picture updated successfully'}), 200
    else:
        return jsonify({'message': 'User not found or image not updated'}), 404

# ---------- NEW: Get profile picture ----------
@app.route('/get-profile-picture', methods=['GET'])
def get_profile_picture():
    email = request.args.get('email')

    if not email:
        return jsonify({'message': 'Missing email'}), 400

    user = users_collection.find_one({'email': email})

    if not user or 'profile_picture' not in user:
        return jsonify({'message': 'No profile picture found'}), 404

    # Return image as base64
    encoded_image = base64.b64encode(user['profile_picture']).decode('utf-8')
    return jsonify({'image': encoded_image}), 200




def preprocess_image_binary(image_bytes):
    np_arr = np.frombuffer(image_bytes, np.uint8)
    image_bgr = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)
    image_rgb = cv2.cvtColor(image_bgr, cv2.COLOR_BGR2RGB)
    image_resized = cv2.resize(image_rgb, (32, 32))
    image_normalized = image_resized.astype(np.float32) / 255.0
    image_batch = np.expand_dims(image_normalized, axis=0)
    return image_batch

@app.route('/validate-olive', methods=['POST'])
def validate_olive():
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400

    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No file selected'}), 400

    try:
        image = preprocess_image_binary(file.read())  # ✅ Use correct function
        prediction = model2.predict(image)

        predicted_class = int(np.argmax(prediction[0]))  # 0 or 1
        confidence = float(np.max(prediction[0]) * 100)

        status = "olive leaf" if predicted_class == 1 else "not olive leaf"
        return jsonify({'status': status, 'confidence': confidence})

    except Exception as e:
        return jsonify({'error': str(e)}), 500
    


@app.route('/detect-contours', methods=['POST'])
def detect_contours():
    if 'image' not in request.files:
        return {'error': 'No image provided'}, 400

    image_file = request.files['image']
    if image_file.filename == '':
        return {'error': 'No selected file'}, 400

    filename = secure_filename(image_file.filename)
    filepath = os.path.join('temp', filename)
    os.makedirs('temp', exist_ok=True)
    image_file.save(filepath)

    # Read and process the image
    image = cv2.imread(filepath)
    image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    blurred = cv2.GaussianBlur(gray, (5, 5), 0)
    edges = cv2.Canny(blurred, 50, 150)

    # Find contours
    contours, _ = cv2.findContours(edges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    if not contours:
        return {'error': 'No contours found'}, 400

    # Combine all contour points
    all_points = np.vstack(contours)
    x, y, w, h = cv2.boundingRect(all_points)

    # Draw one big green rectangle
    cv2.rectangle(image_rgb, (x, y), (x + w, y + h), (0, 255, 0), 3)

    # Save output
    output_path = os.path.join('temp', 'contours_' + filename)
    cv2.imwrite(output_path, cv2.cvtColor(image_rgb, cv2.COLOR_RGB2BGR))

    return send_file(output_path, mimetype='image/jpeg')


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
