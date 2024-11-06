import replicate
import requests
from PIL import Image
from io import BytesIO
from dotenv import load_dotenv
import os
from utils import *
from flask import Flask, request, jsonify
from huggingface_hub import hf_hub_download, snapshot_download
import shutil

load_dotenv()
rep_token = os.getenv("REPLICATE_API_TOKEN")
hf_token = os.getenv("HUGGINGFACE_API_TOKEN")

# prompt = f"duxari, a dog with white and light brown fur, is immortalized as a statue in a grand museum. The statue, carved from smooth marble, captures duxari in a playful pose, one paw slightly raised as if about to pounce. His fur is meticulously detailed, and his expressive eyes seem to gleam with life despite the stone. The statue is displayed on a polished pedestal, surrounded by soft lighting that accentuates the intricate craftsmanship. Visitors marvel at the lifelike representation, the museum's hushed atmosphere lending a reverence to duxari's eternal presence."

# prompt2 = "duxari, a small dog with a mix of white and light brown fur, is sitting on a Victorian-style armchair in an ornate library. The walls are lined with shelves filled with leather-bound books, and the room is illuminated by a grand chandelier hanging from the ceiling. duxari is wearing a velvet smoking jacket and a monocle, exuding an air of sophistication. On a nearby table, an antique globe and a decanter of fine whiskey are visible, adding to the ambiance of the scene. The soft glow of a fireplace casts warm shadows across the room, creating a cozy, luxurious atmosphere as duxari gazes thoughtfully into the distance."

# prompt2 = f"duxari, a small dog with white and light brown fur, panting, sits confidently behind the wheel of a sleek, brightly colored race car. His racing helmet, complete with a visor, is snugly fitted on his head, and a custom racing suit with his name stitched on the back completes the look."

prompt = "duxari, a small dog with white and light brown fur, sits proudly on the front steps of a charming, old-fashioned house, the kind you'd see in a black-and-white photograph from the 1950s. The house is painted in a soft, muted shade, with a white picket fence surrounding a well-tended garden full of blooming roses and hydrangeas. duxari's fur contrasts beautifully with the grayscale surroundings, making him the focal point of the scene. The steps he sits on are slightly worn, the wood smoothed by years of use, and the porch is adorned with a classic swing that creaks gently in the breeze. The sun is low in the sky, casting long shadows across the yard, and there's a nostalgic feel to the whole scene, as if capturing a moment in time that's long passed but fondly remembered."

base_model_url = "lucataco/flux-dev-lora:091495765fa5ef2725a175a57b276ec30dc9d39c22d30410f2ede68a3eab66b3"

step_start = 1000
step_end = 4100
lora_1_url = f"https://huggingface.co/CapGo/duncan_flux/resolve/main/duncan-flux-step00004000.safetensors"
lora_1_name = "dunc_flex_hf"

base_model_name = "CapGo/duncan_flux"

lora_scale_range = [0.8, 0.9, 1.0]
guidance_scale_range = [1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5]

def test_lora_scale_range(prompt, base_model_url, base_model_name, lora_1_url, lora_1_name, step_start, step_end, lora_scale_range, guidance_scale_range):
  dir_check(lora_1_name)
  html_filename = create_index_page(lora_1_name)
  step_range = range(step_start, step_end, 500)
  try:
    for s in step_range:
      temp_lora_1_url = lora_1_url + f"{s}.safetensors"
      for l1 in lora_scale_range:
        for g in guidance_scale_range:
          img = gen_image(prompt, base_model_url, g, 30, lora_1=temp_lora_1_url, l1=l1)
          img_filename = save_image(img, s, g, base_model_name, lora_name=lora_1_name, l1=l1)
          add_image_html(html_filename, img_filename)

    print("Image generation completed")
    close_html(html_filename)

  except replicate.exceptions.ReplicateError as e:
    print(f"ReplicateError: {e}")

# test_lora_scale_range(prompt, base_model_url, base_model_name, lora_1_url, lora_1_name, step_start, step_end, lora_scale_range, guidance_scale_range)

lora_name = "dunc_4000_step"
l1 = 0.9
g_scale = 3.0
inference_steps = 30
img = image = gen_image(prompt, base_model_url, g_scale, inference_steps, lora_1=lora_1_url, l1=l1)
save_image(img, 30, 3.0, base_model_name, lora_name, l1=1)