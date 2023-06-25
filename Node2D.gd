extends Node2D

var image = Image.new()
var brush_color = Color(1, 1, 1, 1)
var texture = ImageTexture.new()
var eraser_mode = false
var mouse_down = false

func _ready():
	var sprite = Sprite.new()
	var bg = load("res://tinypixelart.png")
	sprite.set_texture(bg)
	sprite.set_scale(Vector2(1280.0 / bg.get_width(), 823.0 / bg.get_height()))
	sprite.set_position(Vector2(640, 360))
	add_child(sprite)
	sprite.set_z_index(-20)
	
	image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0)) 
	image.lock()
	texture.create_from_image(image)
	texture.flags = texture.flags & ~Texture.FLAG_FILTER

	var save_button = Button.new()
	save_button.text = "Save"
	save_button.connect("pressed", self, "_on_SaveButton_pressed")
	save_button.set_position(Vector2(0, 5)) 
	add_child(save_button)


	var pencil_button = Button.new()
	pencil_button.text = "Pen"
	pencil_button.connect("pressed", self, "_on_PencilButton_pressed")
	pencil_button.set_position(Vector2(100, 5))
	add_child(pencil_button)

	var eraser_button = Button.new()
	eraser_button.text = "Erase"
	eraser_button.connect("pressed", self, "_on_EraserButton_pressed")
	eraser_button.set_position(Vector2(200, 5))
	add_child(eraser_button)

	var clear_button = Button.new() 
	clear_button.text = "Clear"
	clear_button.connect("pressed", self, "_on_ClearButton_pressed")
	clear_button.set_position(Vector2(300, 5))
	add_child(clear_button)

	var color_picker = ColorPicker.new() 
	color_picker.connect("color_changed", self, "_on_ColorPicker_color_changed")
	
	var scale_factor = 8
	var canvas_size = texture.get_size() * scale_factor
	var canvas_position = (get_viewport_rect().size - canvas_size) / 2
	color_picker.set_position(Vector2(canvas_position.x + canvas_size.x + 10, canvas_position.y))
	
	color_picker.rect_scale = Vector2(0.5, 0.5)
	
	add_child(color_picker)

	var canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)

	var file_dialog = FileDialog.new()
	file_dialog.set_title("Save Sprite")
	file_dialog.set_access(FileDialog.ACCESS_FILESYSTEM)
	file_dialog.set_mode(FileDialog.MODE_SAVE_FILE)
	file_dialog.add_filter("*.png ; Archivo PNG")
	file_dialog.connect("file_selected", self, "_on_FileDialog_file_selected")
	file_dialog.set_current_file("sprite.png")
	canvas_layer.add_child(file_dialog)
	canvas_layer.set_name("CanvasLayer")
	file_dialog.set_name("FileDialog")
	color_picker.set_name("ColorPicker")
		
func _draw():
		var scale_factor = 8
		var canvas_size = texture.get_size() * scale_factor
		var canvas_position = (get_viewport_rect().size - canvas_size) / 2
		draw_texture_rect(texture, Rect2(canvas_position, canvas_size), false)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			mouse_down = event.pressed
			if mouse_down:
				_draw_pixel_at_mouse_position()
	elif event is InputEventMouseMotion:
		if mouse_down:
			_draw_pixel_at_mouse_position()

func _draw_pixel_at_mouse_position():
			var scale_factor = 8
			var canvas_size = texture.get_size() * scale_factor
			var canvas_position = (get_viewport_rect().size - canvas_size) / 2
			var pos = (get_local_mouse_position() - canvas_position) / scale_factor
			if pos.x >= 0 and pos.x < image.get_width() and pos.y >= 0 and pos.y < image.get_height():
				image.lock() 
				if eraser_mode:
					image.set_pixelv(pos.floor(), Color(0, 0, 0, 0)) 
				else:
					image.set_pixelv(pos.floor(), brush_color)
				texture.set_data(image)
				update()

func _on_SaveButton_pressed():
			get_node("CanvasLayer/FileDialog").popup_centered_ratio()

func _on_PencilButton_pressed():
			eraser_mode = false
			brush_color = Color(1, 1, 1, 1)

func _on_EraserButton_pressed():
			eraser_mode = true

func _on_ClearButton_pressed(): 
			image.fill(Color(0, 0, 0, 0))
			texture.set_data(image)
			update()

func _on_ColorPicker_color_changed(color): 
			brush_color = color

func _on_FileDialog_file_selected(path):
	var scaled_image = image.duplicate()
	scaled_image.resize(1000, 1000, Image.INTERPOLATE_NEAREST)
	scaled_image.save_png(path.replace(".jpg", ".png"))
