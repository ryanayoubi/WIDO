extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_node("Exit").pressed:
		get_tree().quit()
		#TO DO: save
	if get_node("Restart").pressed:
		layer=-2
		get_node("Restart").disabled=true
		get_node("Exit").disabled=true
		var dict = {
		"pos_x" : 350,
		"pos_y" : -100,
		"vel_x" : 0,
		"vel_y" : 1000,
		"seconds" : 0,
		"minutes" : 0,
		"hours" : 0,
		"power" : false
		}
		var save_game = File.new()
		save_game.open("user://savegame.save", File.WRITE)
		save_game.store_line(to_json(dict))
		save_game.close()
		get_parent().get_node("Player").load_game()
		get_parent().get_node("Player").intro_ani()
		get_parent().get_node("Player").won=false
	if Input.is_action_just_pressed("ui_cancel"):
		if layer==5:
			layer=-2
			get_node("Restart").disabled=true
			get_node("Exit").disabled=true
		else:
			layer=5
			get_node("Restart").disabled=false
			get_node("Exit").disabled=false
