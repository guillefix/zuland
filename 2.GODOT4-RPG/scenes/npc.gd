extends CharacterBody2D

var httpRequest = HTTPRequest.new()
var dialogue_box = null
var json = JSON.new()
var direction = Vector2()
var enemy = null
var target = null
var npc2 = null
var npc2_area = null
var is_conversation = true

var speed = 200
var enemy_distance_threshold = 10.0  # The distance at which the NPC will stop moving towards the enemy
var conversation_distance_threshold = 10.0  # The distance at which the NPC will start a conversation
var is_attacking = false  # Add this new variable
var is_walking_towards_npc = false

func _ready():
	add_child(httpRequest)
	dialogue_box = get_node("Dialogue")
	enemy = get_node("/root/world/enemy")
	npc2 = get_node("/root/world/Npc2")  #
	npc2_area = get_node("Area2D")
	$walk_timer.start()  # start the timer


func _physics_process(delta):
	if is_attacking:
		attack_enemy()
	elif is_walking_towards_npc:
		walk_towards_npc()
	#move_and_slide()


func start_attacking():
	is_attacking = true
	print("Is attacking?" , is_attacking)
	is_walking_towards_npc = false
	_on_walk_timer_timeout()  # generate a new random direction immediately
	
func start_walking_towards_npc():
	is_attacking = false
	is_walking_towards_npc = true
	_on_walk_timer_timeout()  #

func attack_enemy():
	if enemy != null and global_position.distance_to(enemy.global_position) > enemy_distance_threshold:
		#print("Is atacking Enemy!",direction)
		position += (enemy.position - position)/100
		print("Position",position)
	else:
		direction = Vector2.ZERO

func _on_walk_timer_timeout():
	pass
	# Generate a new random direction
	#direction = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()/10
	
func walk_towards_npc():
	if npc2 != null and global_position.distance_to(npc2.global_position) > conversation_distance_threshold:
		position += (npc2.position - position)/100
	elif is_conversation:
		direction = Vector2.ZERO
		print("starting conversation after walk")
		npc2_area.start_conversation("Hi, whats your name?")
		is_conversation = false
		
