from typing import Set, FrozenSet

# Supported image formats for saving with PIL's Image.save() method
# Source: Pillow documentation (https://pillow.readthedocs.io/en/stable/handbook/image-file-formats.html)
SUPPORTED_SAVE_FORMATS: FrozenSet[str] = frozenset({
    "bmp", "blp", "dds", "eps", "gif", "icns", "ico", "jpeg", "jpg",
    "msp", "pcx", "png", "ppm", "sgi", "tga", "tiff", "webp", "xbm",
    "palm", "pdf", "xv"
})

def get_allowed_formats(allowed: Set[str] = None) -> FrozenSet[str]:
    """
    Get a set of allowed image formats for saving with PIL.

    Args:
        allowed: Optional set of format strings to filter supported formats.
                 If None, returns all supported formats. Case-insensitive.

    Returns:
        FrozenSet[str]: Set of allowed format extensions (lowercase).

    Example:
        >>> get_allowed_formats({"jpg", "png"})
        frozenset({'jpg', 'png'})
        >>> get_allowed_formats()
        frozenset({'bmp', 'blp', 'dds', ..., 'xv'})
    """
    if allowed is None:
        return SUPPORTED_SAVE_FORMATS
    # Ensure case-insensitive matching and validate against supported formats
    return frozenset(fmt.lower() for fmt in allowed if fmt.lower() in SUPPORTED_SAVE_FORMATS)
