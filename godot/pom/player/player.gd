extends CharacterBody2D

@export var player_speed = 300
@export var gravity = 30
@export var jump_strength = 700

@onready var _animated_sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity.y += gravity
		_animated_sprite.play("jump")
	elif velocity.x == 0:
		_animated_sprite.play("idle")
	else:
		_animated_sprite.play("run")
		
	if Input.is_action_just_pressed("player_jump") && is_on_floor():
		velocity.y = -jump_strength
		_animated_sprite.play("jump")
	
	var horizontal_direction = Input.get_axis("player_move_left", "player_move_right")
	
	velocity.x = player_speed * horizontal_direction
	
	if horizontal_direction < 0:
		_animated_sprite.flip_h = true;
	elif horizontal_direction > 0:
		_animated_sprite.flip_h = false;
	
	move_and_slide()
