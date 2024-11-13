from dotenv import load_dotenv
import os

load_dotenv(os.path.join(os.path.dirname(__file__), "../.env.shared"))
load_dotenv(os.path.join(os.path.dirname(__file__), ".env"))

class Config:
  CIVITAI_API_TOKEN = os.getenv("CIVITAI_API_TOKEN")
  HUGGING_FACE_TOKEN = os.getenv("HUGGING_FACE_TOKEN")