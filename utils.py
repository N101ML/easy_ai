import replicate
import requests
from PIL import Image
from io import BytesIO
import os

def save_image(img_url, lora_name, version, l1, l2, g_scale):
  response = requests.get(img_url)
  img = Image.open(BytesIO(response.content))
  filename = f"{lora_name}_{version}_l1_{l1}_l2_{l2}_g_{g_scale}.webp"
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
def gen_image(prompt, model, dunc_lora, other_lora, l1, l2, g_scale):
  output = replicate.run(
    model,
    input={
      "prompt": prompt,
      "hf_loras": [f"{dunc_lora}", f"{other_lora}"],
      "lora_scales": [l1,l2],
      "num_outputs": 1,
      "aspect_ratio": "1:1",
      "output_format": "webp",
      "guidance_scale": g_scale,
      "output_quality": 80,
      "prompt_strength": 0.8,
      "num_inference_steps": 30,
      "disable_safety_checker": True
    }
  )
  return output[0]

# Ensure the directory exists
def dir_check(lora_name, version):
  output_dir = f"{lora_name}/{version}"
  if not os.path.exists(output_dir):
    os.makedirs(output_dir)

# Create HTML file to append image info to
def create_index_page(lora_name, version):
  html_filename = f"{lora_name}/index_{version}.html"

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