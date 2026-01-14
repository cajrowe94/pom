extends CharacterBody2D

@export var player_speed = 300
@export var gravity = 30
@export var jump_strength = 700
@export var max_jump = 1.0

@onready var _animated_sprite = $AnimatedSprite2D

var jump_key_duration = 0.0
var ended_jump = true
var released_jump_key = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	if !is_on_floor():
		# jump key duration determines height of jump
		if Input.is_action_pressed("player_jump") && jump_key_duration < max_jump:
			# jump higher
			velocity.y -= jump_key_duration
			jump_key_duration += 0.1
		elif Input.is_action_pressed('player_jump') && released_jump_key:
			velocity.y += 0
		else:
			# end jump, fall to floor at full speed
			#ended_jump = true
			#jump_key_duration = 0.0
			velocity.y += gravity
		_animated_sprite.play("jump")
	elif velocity.x == 0:
		#released_jump_key = true
		_animated_sprite.play("idle")
	else:
		#released_jump_key = true
		_animated_sprite.play("run")
		
	if Input.is_action_just_pressed("player_jump") && is_on_floor():
		#ended_jump = false
		released_jump_key = false
		jump_key_duration = 0.0
		velocity.y = -jump_strength
		_animated_sprite.play("jump")
	
	if Input.is_action_just_released('player_jump'):
		released_jump_key = true
		
	
	var horizontal_direction = Input.get_axis("player_move_left", "player_move_right")
	
	velocity.x = player_speed * horizontal_direction
	
	if horizontal_direction < 0:
		_animated_sprite.flip_h = true;
	elif horizontal_direction > 0:
		_animated_sprite.flip_h = false;
	
	move_and_slide()
