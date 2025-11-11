from pymongo import MongoClient
import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Get the MongoDB URI from the .env file
uri = os.getenv("MONGO_URI")

try:
    client = MongoClient(
        uri,
        serverSelectionTimeoutMS=5000,
        tls=True,
        tlsAllowInvalidCertificates=True,  # Allow invalid certificates (useful for dev)
        tlsAllowInvalidHostnames=True      # Allow invalid hostnames (useful for dev)
    )
    # Force connection on a request
    client.server_info()
    print("✅ Connexion MongoDB réussie !")
except Exception as e:
    print("❌ Erreur de connexion MongoDB :", e)
