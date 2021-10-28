extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused=true


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	get_tree().paused=false
	get_node("TextureRect").visible=false
	layer=-20
	get_node("Button").disabled=true
	get_node("Button2").disabled=true


func _on_Button2_pressed():
	get_tree().quit()
