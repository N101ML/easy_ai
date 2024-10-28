import replicate
import requests
from PIL import Image
from io import BytesIO
# from dotenv import load_dotenv
import os
from utils import *
from flask import Flask, request, jsonify

# load_dotenv()
# print(os.getenv("REPLICATE_API_TOKEN"))

# # Define the prompt and model
# model = "lucataco/flux-dev-multi-lora:2389224e115448d9a77c07d7d45672b3f0aa45acacf1c5bcf51857ac295e3aec"

# dunc_lora = "CapGo/duncify_test"
# token = "&token=" + os.getenv("CIVITAI_REPLICATE_TOKEN")
# other_lora = "https://civitai.com/api/download/models/734405?type=Model&format=SafeTensor" + token
# other_lora_name = "pc98_style"
# version = "mk12"

# trigger_word = "pc98style"
# dunc_trigger = "dunc, a dog with white and light brown fur"
# lora_1_range = [0.8, 0.9, 1.0]
# lora_2_range = [0.9, 1.0]
# standard_lora = 0.8
# g_scale = [1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5]
# prompt = f"An anthro {dunc_trigger} piloting a star fighter in the cockpit wearing a helmet distracted in a space battle with a playstation-esque video game HUD on the screen in {trigger_word}"
# "An anthro {lora_1} piloting a star fighter in the cockpit wearing a helmet distracted in a space battle with a playstation-esque video game HUD on the screen in {lora_2}"

# test_lora_1 = 0.8
# test_lora_2 = 1.0
# test_g_scale = 1.5

# img = gen_image(prompt, model, dunc_lora, other_lora, test_lora_1, test_lora_2, test_g_scale)
# img_filename = save_image(img, other_lora_name, version, test_lora_1, test_lora_2, test_g_scale)

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