from PIL import Image

# -------------------
# Demo of image slicing
# input is 1224 × 5817 pixels
# remove top 297 pixels
# remaining rows will get translated into rows of [1 , 2 , 3
                                                   4 , 5 , 6 
                                                   ........ ]
# output image is 3672 × 1840
# -------------------
INPUT_PATH = "input.jpg"
OUTPUT_PATH = "output.jpg"

REMOVE_TOP = 297
ROW_HEIGHT = 230
COLUMNS = 3

# -------------------
# Load image
# -------------------
img = Image.open(INPUT_PATH)
width, height = img.size

assert (width, height) == (1224, 5817), "Unexpected input dimensions"

# -------------------
# Remove top 297 pixels
# -------------------
content = img.crop((0, REMOVE_TOP, width, height))
_, content_height = content.size

assert content_height == 5520, "Height after crop must be 5520"
assert content_height % ROW_HEIGHT == 0, "Height must divide cleanly"

num_rows = content_height // ROW_HEIGHT
assert num_rows == 24, "Expected exactly 24 rows"

# -------------------
# Create output canvas
# -------------------
out_width = width * COLUMNS          # 3672
out_height = (num_rows // COLUMNS) * ROW_HEIGHT  # 1840

output = Image.new("RGB", (out_width, out_height))

# -------------------
# Slice + append
# -------------------
for i in range(num_rows):
    # Crop one 230px row
    y0 = i * ROW_HEIGHT
    y1 = y0 + ROW_HEIGHT
    row = content.crop((0, y0, width, y1))

    # Compute destination
    col = i % COLUMNS
    row_block = i // COLUMNS

    x = col * width
    y = row_block * ROW_HEIGHT

    output.paste(row, (x, y))

# -------------------
# Save
# -------------------
output.save(OUTPUT_PATH)
print("Saved output.png (3672 × 1840)")
