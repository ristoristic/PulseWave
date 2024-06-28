import PIL.Image
import PIL.ImageDraw
import PIL.ImageFont

def create_grb_designs():
    # Define image size and create a new image with transparency
    img_size = (500, 1500)
    img = Image.new('RGBA', img_size, (255, 255, 255, 0))
    
    draw = ImageDraw.Draw(img)
    
    # Define font
    font_path = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"  # Adjust this path to where your font is located
    font_size = 20
    font = ImageFont.truetype(font_path, font_size)
    
    def draw_shield(draw, coords, color, text, font, text_color):
        draw.polygon(coords, outline=color, fill=(255, 255, 255, 255))
        text_width, text_height = draw.textsize(text, font=font)
        text_position = (coords[0][0] + (coords[1][0] - coords[0][0]) / 2 - text_width / 2, 
                         coords[2][1] + 10)
        draw.text(text_position, text, fill=text_color, font=font)

    # Coordinates for shield
    shield_coords = [(150, 50), (350, 50), (300, 300), (200, 300)]
    
    # Modern minimalist design
    draw_shield(draw, shield_coords, "blue", "FK Sloboda", font, "blue")
    draw.ellipse([(210, 70), (290, 150)], outline="blue", width=5)
    
    # Move coordinates down for next design
    shield_coords = [(x, y + 400) for x, y in shield_coords]
    
    # Symbolic design
    draw_shield(draw, shield_coords, "red", "Sloboda Mrtvica", font, "red")
    draw.line([(250, 70 + 400), (250, 150 + 400)], fill="red", width=5)
    
    # Move coordinates down for next design
    shield_coords = [(x, y + 400) for x, y in shield_coords]
    
    # Dynamic design
    draw_shield(draw, shield_coords, "green", "FK Sloboda 1953", font, "green")
    draw.arc([(200, 50 + 800), (300, 150 + 800)], start=0, end=180, fill="green", width=5)
    
    return img

# Create the image
img = create_grb_designs()

# Save the image
img_path = "c:/Users/Risto/Desktop/grb_redesign_proposals_detailed.png"
img.save(img_path)

# Show the image
img.show()
