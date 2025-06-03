#Grok 3 refined
from PIL import Image
import re

def extract_metadata(image_path: str) -> dict:
    """Extract metadata from a PNG image and return it as a dictionary."""
    try:
        with Image.open(image_path) as img:
            metadata = img.info
            if "parameters" not in metadata:
                print(f"No parameters in metadata for {image_path}")
                return {}

            # Split parameters into lines
            params = metadata["parameters"].split("\n")
            if len(params) < 2:
                print(f"Invalid metadata format in {image_path}")
                return {}

            # Extract positive and negative prompts
            positive_prompt = params[0]
            negative_prompt = params[1].split(": ", 1)[1] if ": " in params[1] else ""

            # Find and parse steps information
            steps_index = metadata["parameters"].find("Steps:")
            if steps_index == -1:
                print(f"No Steps found in metadata for {image_path}")
                return {}

            steps_info = metadata["parameters"][steps_index:].split("\nTemplate")[0]
            pattern = r',\s*(?=(?:[^"]*"[^"]*")*[^"]*$)'  # Match commas outside quotes
            steps_list = re.split(pattern, steps_info)

            # Build metadata dictionary
            metadata_dict = {
                "prompt": positive_prompt,
                "negative_prompt": negative_prompt
            }
            for item in steps_list:
                if ": " not in item:
                    continue
                key, value = item.split(": ", 1)
                metadata_dict[key.strip()] = value.strip()

            return metadata_dict

    except Exception as e:
        print(f"Error extracting metadata from {image_path}: {e}")
        return {}