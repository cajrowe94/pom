extends CharacterBody2D

@export var player_speed = 300
@export var gravity = 30
@export var jump_strength = 700
@export var max_jump_boost = 1.0
@export var max_jumps = 2

@onready var _animated_sprite = $AnimatedSprite2D

var jump_key_duration = 0.0
var jump_count = 0
var has_initiated_double_jump = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_animated_sprite.connect("animation_finished", handle_animation_finished)
	
	if is_on_floor():
		_animated_sprite.play("idle")
	else:
		_animated_sprite.play("fall")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	if is_on_floor():
		reset_jump()

	if Input.is_action_just_pressed("player_jump"):
		handle_jump_key_press()
	
	if !is_on_floor():
		if _animated_sprite.animation == "run": # player walked off ledge
			_animated_sprite.play("jump")

		var max_jump_boost_reached = jump_key_duration >= max_jump_boost
		var max_jumps_reached = jump_count > max_jumps
		
		# jump key duration determines height of jump
		# this allows you to do short hops
		if Input.is_action_pressed("player_jump") && !max_jump_boost_reached && !max_jumps_reached:
			if jump_count == 1:
				# first jump
				_animated_sprite.play("jump")
				player_jump(jump_key_duration)
				jump_key_duration += 0.1
			else:
				# double jump
				if !has_initiated_double_jump:
					velocity.y = -jump_strength
					has_initiated_double_jump = true
				else:
					_animated_sprite.play("double_jump")
					player_jump(jump_key_duration)
					jump_key_duration += 0.04 # dbl jump is higher / longer than regular jump
		else:
			player_fall()
	elif velocity.x != 0:
		_animated_sprite.play("run")
	else:
		_animated_sprite.play("idle")
	
	player_run()
	move_and_slide()

# animation_finished callback
func handle_animation_finished() -> void:
	print(_animated_sprite.animation)
	match _animated_sprite.animation:
		"jump", "fall":
			if !is_on_floor():
				_animated_sprite.play("fall")
		"double_jump":
			if !is_on_floor():
				_animated_sprite.play("jump")
				
			

# user presses jump key
func handle_jump_key_press() -> void:
	jump_key_duration = 0.0
	jump_count += 1
	# perform initial jump
	if is_on_floor():
		player_jump(jump_strength)
	elif !is_on_floor() && jump_count == 1: # we jumped after walking off an edge
		jump_count += 1


# reset vars for jump logic
func reset_jump() -> void:
	jump_count = 0
	has_initiated_double_jump = false
	jump_key_duration = 0.0

# add gravity value to player y velocity
func player_fall() -> void:
	velocity.y += gravity

# subtract a value (float) from player's y velocity
func player_jump(jump_val: float) -> void:
	velocity.y -= jump_val

# when player is moving on the x axis
func player_run() -> void:
	var horizontal_direction = Input.get_axis("player_move_left", "player_move_right")
	
	velocity.x = player_speed * horizontal_direction
	
	if horizontal_direction < 0:
		_animated_sprite.flip_h = true;
	elif horizontal_direction > 0:
		_animated_sprite.flip_h = false;
