from flask import Blueprint, request, jsonify
from .gen_image import gen_image
import os

replicate_gen_image_bp = Blueprint('replicate_gen_image_bp', __name__)

@replicate_gen_image_bp.route('/generate_image', methods=['POST'])
def generate_image():
  data = request.json
  prompt = data.get('prompt')
  base_model = data.get('base_model')
  lora_1 = data.get('lora_1')
  lora_2 = data.get('lora_2')
  l1_scale = data.get('l1')
  l2_scale = data.get('l2')
  g_scale = data.get('g_scale')
  steps = data.get('steps')
  num_outputs = data.get('num_outputs')

  images = gen_image(prompt, base_model, g_scale, steps, lora_1, lora_2, l1_scale, l2_scale, num_outputs)

  return jsonify({'images': images})