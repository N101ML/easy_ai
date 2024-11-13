from dotenv import load_dotenv
import os
from .replicate import utils
from flask import Flask, request, jsonify
from .config import Config
from .replicate.routes import replicate_gen_image_bp

def create_app(test_config=None):
  app = Flask(__name__)
  # This is the development config that is being loaded - need to add production
  if test_config is None:
    app.config.from_object(Config)

  # ensure the instance folder exists
  try:
      os.makedirs(app.instance_path)
  except OSError:
      pass

  # Register replicate blueprint
  app.register_blueprint(replicate_gen_image_bp, url_prefix="/replicate")

  return app