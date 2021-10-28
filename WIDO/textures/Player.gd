extends KinematicBody2D

export var speed = 600
export var gravity =1500
export var debug =false

onready var _ground_map = $"/root/Node2D/TileMap"
onready var _animated_sprite = $AnimatedSprite
onready var _area_f = $Area2D
onready var _area_d = $Area2D2
onready var _area_u = $Area2D3

var velocity = Vector2()
var tempvel= velocity
var lastground= 2000

var seconds = 0
var minutes = 0
var hours = 0

var jumped=false

var power = false
var won = false
var text = String()

func save_game():
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	save_game.store_line(to_json(save()))
	save_game.close()

func intro_ani():
	velocity.y=1000
	var t=Timer.new()
	t.set_wait_time(1)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	t.queue_free()
	get_node("Camera2D").limit_top=-10000000

func load_game():
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		intro_ani()
		return # Error! We don't have a save to load.
	save_game.open("user://savegame.save", File.READ)
	while save_game.get_position() < save_game.get_len():
		var node_data = parse_json(save_game.get_line())
		position=Vector2(node_data["pos_x"],node_data["pos_y"])
		velocity=Vector2(node_data["vel_x"],node_data["vel_y"])
		seconds=float(node_data["seconds"])
		minutes=float(node_data["minutes"])
		hours=float(node_data["hours"])
		power=bool(node_data["power"])
	save_game.close()

func save():
	var save_dict = {
		"pos_x" : position.x,
		"pos_y" : position.y,
		"vel_x" : velocity.x,
		"vel_y" : velocity.y,
		"seconds" : seconds,
		"minutes" : minutes,
		"hours" : hours,
		"power" : power
	}
	return save_dict

func get_input():
	if debug:
		if Input.is_action_just_pressed("ui_home"):
			position.x+=(get_viewport().get_mouse_position().x-960)/1.5
			position.y+=(get_viewport().get_mouse_position().y-540)/1.5
			velocity.x=0
			velocity.y=0
	if is_on_floor():
		#lateral movement
		if Input.is_action_pressed("ui_right"):	
			_animated_sprite.flip_h=false
			_animated_sprite.position.x=30
			velocity.x=speed
			_animated_sprite.play("running")
			if(!get_node("AudioStreamPlayer").playing):
				get_node("AudioStreamPlayer").play()
		else:
			if Input.is_action_pressed("ui_left"):
				velocity.x=-1*speed
				_animated_sprite.flip_h=true
				_animated_sprite.position.x=-30
				_animated_sprite.play("running")
				if(!get_node("AudioStreamPlayer").playing):
					get_node("AudioStreamPlayer").play()
			else:
				velocity.x=0
				_animated_sprite.play("idle")
				get_node("AudioStreamPlayer").stop()
	else:
		if _animated_sprite.animation!="bonk":
			#not in a slash animation
			if (_animated_sprite.animation=="fslash"&&_animated_sprite.frame==2)||(_animated_sprite.animation=="dslash"&&_animated_sprite.frame==2)||(_animated_sprite.animation=="uslash"&&_animated_sprite.frame==2):
				_area_f.get_node("AnimatedSprite").play("cum")
				_area_d.get_node("AnimatedSprite").play("cum")
				_area_u.get_node("AnimatedSprite").play("cum")
				#fall
				if velocity.y>0:
					_animated_sprite.play("jumpfall")
				if velocity.y<-1.2*speed:
					_animated_sprite.play("jumprise")
			#flip based on direction
			if Input.is_action_pressed("ui_left"):
				_area_u.scale.x=-1
				_area_d.scale.x=-1
				_area_f.scale.x=-1
			else:
				if Input.is_action_pressed("ui_right"):
					_area_u.scale.x=1
					_area_d.scale.x=1
					_area_f.scale.x=1
			if power:
				#upslashjump
				if Input.is_action_just_pressed("ui_accept")&&Input.is_action_pressed("ui_up"):
					get_node("AudioStreamPlayer2").play()
					if Input.is_action_pressed("ui_right"):
						_area_u.scale.x=1
						_animated_sprite.flip_h=false
						_animated_sprite.position.x=30
					else:
						if Input.is_action_pressed("ui_left"):
							_area_u.scale.x=-1
							_animated_sprite.flip_h=true
							_animated_sprite.position.x=-30
					_animated_sprite.play("idle")
					_animated_sprite.play("uslash")
					_area_f.get_node("AnimatedSprite").play("cum")
					_area_d.get_node("AnimatedSprite").play("cum")
					_area_u.get_node("AnimatedSprite").play("cum")
					_area_u.get_node("AnimatedSprite").play("piss")
					if _area_u.overlaps_body(_ground_map):
						if velocity.y<speed*1.2&&velocity.y>speed*-1.2:
							velocity.y=speed*1.2
						else:
							velocity.y=abs(velocity.y)
				#downslashjump
				if Input.is_action_just_pressed("ui_accept")&&Input.is_action_pressed("ui_down"):
					get_node("AudioStreamPlayer2").play()
					if Input.is_action_pressed("ui_right"):
						_area_d.scale.x=1
						_animated_sprite.flip_h=false
						_animated_sprite.position.x=30
					else:
						if Input.is_action_pressed("ui_left"):
							_area_d.scale.x=-1
							_animated_sprite.flip_h=true
							_animated_sprite.position.x=-30
					_animated_sprite.play("idle")
					_animated_sprite.play("dslash")
					_area_f.get_node("AnimatedSprite").play("cum")
					_area_d.get_node("AnimatedSprite").play("cum")
					_area_u.get_node("AnimatedSprite").play("cum")
					_area_d.get_node("AnimatedSprite").play("piss")
					if _area_d.overlaps_body(_ground_map):
						if velocity.y<speed*1.2&&velocity.y>speed*-1.2:
							velocity.y=-1*speed*1.2
						else:
							velocity.y=-1*abs(velocity.y)
				#righslashjump
				if Input.is_action_pressed("ui_right"):
					if Input.is_action_just_pressed("ui_accept")&&velocity.y!=0:
						get_node("AudioStreamPlayer2").play()
						_animated_sprite.flip_h=false
						_animated_sprite.position.x=30
						_animated_sprite.play("idle")
						_animated_sprite.play("fslash")
						_area_u.get_node("AnimatedSprite").play("cum")
						_area_d.get_node("AnimatedSprite").play("cum")
						_area_f.get_node("AnimatedSprite").play("cum")
						_area_f.get_node("AnimatedSprite").play("piss")
						if _area_f.overlaps_body(_ground_map):
							if velocity.x>-1*speed&&velocity.x<speed:
								velocity.x=-1*speed
							else:
								if velocity.x>0:
									velocity.x=-1.2*velocity.x
								if velocity.x<0:
									velocity.x=1.2*velocity.x
				#leftslashjump
				if Input.is_action_pressed("ui_left"):
					if Input.is_action_just_pressed("ui_accept")&&velocity.y!=0:
						get_node("AudioStreamPlayer2").play()
						_animated_sprite.flip_h=true
						_animated_sprite.position.x=-30
						_animated_sprite.play("idle")
						_animated_sprite.play("fslash")
						_area_u.get_node("AnimatedSprite").play("cum")
						_area_d.get_node("AnimatedSprite").play("cum")
						_area_f.get_node("AnimatedSprite").play("cum")
						_area_f.get_node("AnimatedSprite").play("piss")
						if _area_f.overlaps_body(_ground_map):
							if velocity.x>-1*speed&&velocity.x<speed:
								velocity.x=speed
							else:
								if velocity.x<0:
									velocity.x=-1.2*velocity.x
								if velocity.x>0:
									velocity.x=1.2*velocity.x
		if _animated_sprite.animation=="bonk":
			_area_f.get_node("AnimatedSprite").play("cum")
			_area_d.get_node("AnimatedSprite").play("cum")
			_area_u.get_node("AnimatedSprite").play("cum")
		#bonk
		if is_on_wall()&&!velocity.y==0:
			velocity.x=-0.75*tempvel.x
			_animated_sprite.play("bonk")
			get_node("AudioStreamPlayer4").play()
			if _animated_sprite.flip_h:
				_animated_sprite.flip_h=false
				_animated_sprite.position.x=30
			else:
				_animated_sprite.flip_h=true
				_animated_sprite.position.x=-30
	if is_on_floor():
		if (position.y-lastground)>700:
			get_node("AudioStreamPlayer3").play()
		if jumped||(abs(position.y-lastground)>10):
			jumped=false
			get_node("AudioStreamPlayer4").play()
		lastground=position.y
		_area_f.get_node("AnimatedSprite").play("cum")
		_area_d.get_node("AnimatedSprite").play("cum")
		_area_u.get_node("AnimatedSprite").play("cum")
		#jump
		if Input.is_action_pressed("ui_accept"):
			jumped=true
			velocity.y=-1*speed*1.2
			_animated_sprite.play("jumprise")

func _ready():
	load_game()
	get_node("Camera2D").limit_top=-10000000


func _physics_process(delta):
	save_game()
	get_input()
	if !is_on_floor():
		velocity.y+=gravity*delta
	tempvel=velocity
	velocity = move_and_slide(velocity,Vector2(0,-1))

func _process(delta):
	if(!won):
		seconds+=delta
	if seconds>=60:
		minutes+=1
		seconds = fmod(seconds,60)
	if minutes>=60:
		hours+=1
		minutes = fmod(minutes,60)
	if minutes <10:
		if seconds <10:
			text= String(hours)+":0"+String(minutes)+":0"+String(seconds)
		else:
			text= String(hours)+":0"+String(minutes)+":"+String(seconds)
	else:
		if seconds <10:
			text= String(hours)+":"+String(minutes)+":0"+String(seconds)
		else:
			text= String(hours)+":"+String(minutes)+":"+String(seconds)

func _on_Area2D_body_entered(body):
	power=true


func _on_Area2D2_body_entered(body):
	won=true


func _on_HSlider_value_changed(value):
	get_node("AudioStreamPlayer").volume_db=-10-(100-value)
	get_node("AudioStreamPlayer2").volume_db=-10-(100-value)
	get_node("AudioStreamPlayer3").volume_db=0-(100-value)
	get_node("AudioStreamPlayer4").volume_db=-10-(100-value)
