extends CharacterBody2D

@export var player_speed = 300
@export var gravity = 30

# jump variables
@export var jump_strength = 700
@export var max_jump_boost = 1.0
@export var max_jumps = 2
var jump_key_duration = 0.0
var jump_count = 0
var has_initiated_double_jump = false

# dash variables
@export var dash_speed = 700
@export var dash_cooldown = 30
var dash_countdown = 0
var dash_time = 0
var is_dashing = false

@onready var _animated_sprite = $AnimatedSprite2D

var last_moving_dir = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_animated_sprite.connect("animation_finished", handle_animation_finished)
	handle_player_start_position()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	if is_on_floor():
		reset_jump()

	if Input.is_action_just_pressed("player_jump"):
		handle_jump_key_press()
	
	handle_dash()
	
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

	if !is_dashing:
		player_run()

	move_and_slide()

func handle_player_start_position() -> void:
	if is_on_floor():
		_animated_sprite.play("idle")
	else:
		_animated_sprite.play("fall")

# animation_finished callback
func handle_animation_finished() -> void:
	match _animated_sprite.animation:
		"jump", "fall":
			if !is_on_floor():
				_animated_sprite.play("fall")
		"double_jump":
			if !is_on_floor():
				_animated_sprite.play("jump")
			
# manage dash variables	
func handle_dash() -> void:
	if Input.is_action_just_pressed("player_dash"):
		handle_dash_key_press()

	if dash_countdown > 0:
		dash_countdown -= 1
		
	if dash_time > 0:
		dash_time -= 1
	else:
		is_dashing = false

# user presses dash key
func handle_dash_key_press() -> void:
	if dash_countdown == 0.0:
		player_dash()

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
	var horizontal_dir = get_player_horizontal_dir()
	
	velocity.x = player_speed * horizontal_dir
	
	if horizontal_dir < 0:
		_animated_sprite.flip_h = true;
	elif horizontal_dir > 0:
		_animated_sprite.flip_h = false;

# move the player quickly along x axis
func player_dash() -> void:
	is_dashing = true
	dash_time = 15
	dash_countdown = dash_cooldown
	velocity.x = dash_speed * last_moving_dir
	

func get_player_horizontal_dir() -> float:
	var horizontal_dir = Input.get_axis("player_move_left", "player_move_right")
	
	if horizontal_dir != 0:
		last_moving_dir = horizontal_dir
	
	return horizontal_dir
