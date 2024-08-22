from PIL import Image, ImageDraw

image_size = 768
radius = image_size // 2

image = Image.new("RGBA", (image_size, image_size), (0, 0, 0, 0))
draw = ImageDraw.Draw(image)

draw.ellipse((0, 0, image_size, image_size), outline="black", width = 2)
draw.ellipse((1, 1, image_size - 1, image_size - 1), outline="red", width = 31)
draw.ellipse((31, 31, image_size - 31, image_size - 31), outline="black", width = 2)

file_name = "circle" + str(image_size) + "x" + str(image_size) + ".png"

image.save(file_name, "PNG")

# image.show()