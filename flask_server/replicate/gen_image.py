import replicate
import requests
from PIL import Image
import os

def gen_image(prompt, base_model, g_scale, steps, lora_1=None, lora_2=None, l1=None, l2=None, num_outputs=1):
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
  output = replicate.run(base_model, input=input)
  
  return output