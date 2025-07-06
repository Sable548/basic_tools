#Resize images to 1024x1024, skip small images.

import math
from PIL import Image
import os
from tqdm import tqdm
from typing import Tuple, Optional, FrozenSet

# Fallback if PIL_image_formats module is unavailable
DEFAULT_SAVE_FORMATS: FrozenSet[str] = frozenset({
    "bmp", "eps", "gif", "ico", "jpeg", "jpg", "png", "ppm",
    "tiff", "webp"
})

#Import as an image format reference sheet
try:
    from PIL_image_save_formats import get_allowed_formats
except ImportError:
    def get_allowed_formats(allowed: set[str] = None) -> FrozenSet[str]:
        if allowed is None:
            return DEFAULT_SAVE_FORMATS
        return frozenset(fmt.lower() for fmt in allowed if fmt.lower() in DEFAULT_SAVE_FORMATS)



def get_image_files(directory: str, allowed_extensions: FrozenSet[str] = None) -> list[str]:
    """
    Retrieves a list of image file paths from the given directory.

    Args:
        directory: The path to the directory to search.
        allowed_extensions: Set of allowed file extensions (e.g., {'jpg', 'png'}).
                   If None, uses supported PIL save formats (from image_formats or default).

    Returns:
        A list of strings, where each string is the absolute path to an image file.
        Returns an empty list if the directory does not exist.
    """
    image_paths = []
    if not os.path.exists(directory):
        print(f"Warning: Directory '{directory}' does not exist.")
        return image_paths

    # Get allowed extensions from reference sheet or fallback if not provided
    allowed_extensions = get_allowed_formats(allowed_extensions)

    # Create a image list
    for filename in os.listdir(directory):
        file_path = os.path.join(directory, filename)
        if os.path.isfile(file_path):
            ext = filename.rsplit('.', 1)[-1].lower()
            if ext in allowed_extensions:
                image_paths.append(file_path)
    return image_paths

def resize_down_image(image_path: str, destination_folder: str, resize_to: Tuple[int], img_format: str = 'png') -> None:
    """
    Resizes a single image if its area is larger than the specified size.

    Args:
        image_path: The path to the image file.
        destination_folder: The folder to save the resized image to.
        resize_to: A tuple (width, height) specifying the desired size.
        img_format: The format to save the resized image as (default: 'png').
    """
    try:
        with Image.open(image_path) as img:
            img_width, img_height = img.size
            final_w, final_h = resize_to

            current_size = img_width * img_height
            final_size = final_w * final_h
            

            if current_size > final_size:
                resize_factor = (img_width * img_height) / final_size
                new_width = round(img_width / math.sqrt(resize_factor))
                new_height = round(img_height / math.sqrt(resize_factor))

                img_resized = img.resize((new_width, new_height))
                
            elif current_size == final_size:
                img_resized = img #copy the image as equal size
                
            else:
                return
                
            # Create new file name and path
            base_name = os.path.basename(image_path).rsplit('.', 1)[0]
            new_filename = f"{base_name}.{img_format}"
            new_file_path = os.path.join(destination_folder, new_filename)

            # Save the resized image
            img_resized.save(new_file_path, format=img_format.upper())
    except FileNotFoundError:
        print(f"Error: File not found: {image_path}")
        
        error_type = type(e).__name__  # Get the class name
        error_message = str(e).split('\n')[0]  # Get the full error message
        print(f"{error_type}: {error_message}")

    except Exception as e:
        print(f"Error processing {image_path}: {e}")

        error_type = type(e).__name__  # Get the class name
        error_message = str(e).split('\n')[0]  # Get the full error message
        print(f"{error_type}: {error_message}")
        


def batch_resize_down_image(original_directory: str, destination_folder: str, resize_to: Tuple[int], img_format: str = 'png') -> None:
    """
    Resizes all images in the original directory and saves them to the destination folder.

    Args:
        original_directory: The path to the directory containing the images.
        destination_folder: The path to the directory to save the resized images to.
        resize_to: A tuple (width, height) specifying the desired size.
        img_format: The format to save the resized images as (default: 'png').
    """
    # Get the image files
    image_resize_list = get_image_files(original_directory)

    # Create the destination folder if it doesn't exist
    os.makedirs(destination_folder, exist_ok=True)

    # Resize each image
    for image_path in tqdm(image_resize_list, desc="Resizing Images"):
        resize_down_image(image_path, destination_folder, resize_to, img_format)


if __name__ == "__main__":
    # Settings
    image_directory = r'C:\Users\Name\project\original'
    destination_folder = r'C:\Users\Name\project\new'
    final_size = (1024, 1024)
    out_format = 'png'

    # Execution
    batch_resize_down_image(image_directory, destination_folder, final_size, img_format=out_format)
