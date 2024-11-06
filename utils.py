import replicate
import requests
from PIL import Image
from io import BytesIO
import os
from gradio_client import Client

def save_image(img_url, step_count, g_scale, base_model_name="", lora_name="", l1=None):
  # Get URL
  response = requests.get(img_url)
  img = Image.open(BytesIO(response.content))

  if lora_name:
    filename = f"{lora_name}_{step_count}_g_{g_scale}_l1_{l1}"
  else:
     filename = f"{base_model_name}__{step_count}_g_{g_scale}"
  
  filename += ".webp"
  
  img.save(filename)
  print(f"Saved image as {filename}")
  return filename

def add_image_html(html_filename, img_filename):
  # Append to HTML file
  with open(html_filename, "a") as f:
    f.write(f"<div class='image-container'>\n")
    f.write(f"<img src='{img_filename}' alt='{os.path.basename(img_filename)}'>\n")
    f.write(f"<p>{os.path.basename(img_filename)}</p>\n")
    f.write(f"</div>\n")

# Generate images
def gen_image(prompt, base_model_url, g_scale, steps, lora_1=None, lora_2=None, l1=None, l2=None, num_outputs=1):
  # Initialize without LoRAs
  input={
    "prompt": prompt,
    "num_outputs": num_outputs,
    "aspect_ratio": "1:1",
    "output_format": "webp",
    "guidance_scale": g_scale,
    "output_quality": 80,
    "prompt_strength": 0.8,
    "num_inference_steps": steps,
    "disable_safety_checker": True
  }
  
  # Add LoRAs if present
  hf_loras, lora_scales = [], []

  if lora_1:
    hf_loras.append(lora_1)
    lora_scales.append(l1)
  if lora_2:
    hf_loras.append(lora_2)
    lora_scales.append(l2)

  if len(lora_scales) == 2:
    input["hf_loras"] = hf_loras
    input["lora_scales"] = lora_scales
  elif len(lora_scales) == 1:
    input["hf_lora"] = hf_loras[0]
    input["lora_scale"] = lora_scales[0]

  # Call to replicate
  output = replicate.run(base_model_url, input=input)
  
  return output[0]

# Ensure the directory exists
def dir_check(lora_name):
  output_dir = f"{lora_name}"
  if not os.path.exists(output_dir):
    os.makedirs(output_dir)

# Create HTML file to append image info to
def create_index_page(lora_name):
  html_filename = f"{lora_name}/index.html"
  os.makedirs(lora_name, exist_ok=True)  # Ensure the directory exists

  with open(html_filename, "w") as f:
    f.write("<!DOCTYPE html>\n<html lang='en'>\n<head>\n<meta charset='UTF-8'>\n<title>Generated Images</title>\n")
    f.write("<style>\n.album { display: flex; flex-wrap: wrap; }\n.image-container { margin: 10px; text-align: center; }\n.image-container img { max-width: 500px; height: auto; }\n</style>\n")
    f.write("</head>\n<body>\n<div class='album'>\n")
  
  return html_filename

def close_html(html_filename):
  # Close the HTML structure
  with open(html_filename, "a") as f:
    f.write("</div>\n</body>\n</html>")

# Testing Loras
def test_lora(prompt, model, dunc_lora, other_lora, other_lora_name, version, lora_1_range, lora_2_range, standard_lora, g_scale, html_filename):
  try:
    for g in g_scale:
      # Iterate through l1 range:
      for l1 in lora_1_range:
        img = gen_image(prompt, model, dunc_lora, other_lora, l1, standard_lora, g)
        img_filename = save_image(img, other_lora_name, version, l1, standard_lora, g)
        add_image_html(html_filename, img_filename)

      # Iterate through l2 range:
      for l2 in lora_2_range:
        img = gen_image(prompt, model, dunc_lora, other_lora,standard_lora, l2, g)
        img_filename = save_image(img, other_lora_name, version, standard_lora, l2, g)
        add_image_html(html_filename, img_filename)

    print("Image generation completed")

  except replicate.exceptions.ReplicateError as e:
    print(f"ReplicateError: {e}")

def refine_lora(prompt, model, dunc_lora, other_lora, other_lora_name, lora_2_range, standard_lora, g_scale):
  for g in g_scale:

    # Iterate through l2 range:
    for l2 in lora_2_range:
      img = gen_image(prompt, model, dunc_lora, other_lora, standard_lora, l2, g)
      save_image(img, other_lora_name, standard_lora, standard_lora, g)

def replicate_training(destination, version, steps, optimizer, trigger_word, resolution):
  output = replicate.trainings.create(
    destinaion=destination, # This is the replicate model we are going to save to
    version=version,
    input={
      "steps": steps,
      "lora_rank": 64,
      "optimizer": optimizer,
      "batch_size": 1,
      "resolution": resolution,
      "autocaption": True,
      "input_images": "", # This should be a zip file
      "trigger_word": trigger_word,
      "learning_rate": 0.0005,
      "caption_dropout_rate": 0.05,
      "cache_latents_to_disk": False,
    },
  )
  return output

def generate_html_for_images(lora_name, version, image_folder):
  html_filename = create_index_page(lora_name, version)

  # Iterate through each image file in the folder
  for img_filename in os.listdir(image_folder):
      full_img_path = os.path.join(image_folder, img_filename)
      if os.path.isfile(full_img_path):  # Check if it's a file
          add_image_html(html_filename, full_img_path)
  
  close_html(html_filename)
  print(f"HTML file created at: {html_filename}")