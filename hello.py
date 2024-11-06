import replicate
import requests
from PIL import Image
from io import BytesIO
from dotenv import load_dotenv
import os
from utils import *
from flask import Flask, request, jsonify
from huggingface_hub import hf_hub_download


app = Flask(__name__)

@app.route('/generate_image', methods=['POST'])
def generate_image():
  data = request.json
  prompt = data.get('prompt')
  model = data.get('model')
  lora_1 = data.get('lora_1')
  lora_2 = data.get('lora_2')
  l1_scale = data.get('l1_scale')
  l2_scale = data.get('l2_scale')
  g_scale = data.get('g_scale')
  steps = data.get('steps')

  image_url = gen_image(prompt, model, lora_1, lora_2, l1_scale, l2_scale, g_scale, steps)

  return jsonify({'image_url': image_url})

if __name__ == '__main__':
  app.run(debug=True)