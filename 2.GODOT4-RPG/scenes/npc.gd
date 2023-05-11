extends CharacterBody2D

var httpRequest = HTTPRequest.new()
var dialogue_box = null
var json = JSON.new()
var direction = Vector2()
var enemy = null
var target = null
var npc = null
var npc2 = null
var npc3 = null
var npc4 = null
var npc2_area = null
var is_conversation = true
var area = null

var speed = 2000
var enemy_distance_threshold = 10.0  # The distance at which the NPC will stop moving towards the enemy
var conversation_distance_threshold = 10.0  # The distance at which the NPC will start a conversation
var is_attacking = false  # Add this new variable
var is_walking_towards_npc = false

var close_npc_list = []
var npc_lists = []
var walking_towards = "none"
var current_dir = null

func _ready():
	add_child(httpRequest)
	dialogue_box = get_node("Dialogue")
	enemy = get_node("/root/world/enemy")
	npc = get_node("/root/world/Npc")  #	
	npc2 = get_node("/root/world/Npc2")  #
	npc3 = get_node("/root/world/Npc3")  #	
	npc4= get_node("/root/world/Npc4")  #		
	area = $action_area
	area.send_request("start game")
	$walk_timer.start()  # start the timer


func _physics_process(delta):
	#npc_movement(current_dir)
	if is_attacking:
		attack_enemy()
	#elif is_walking_towards_npc:
		#walk_towards_npc(walking_towards)

	if walking_towards == "npc1":
		walk_towards_npc1()
	elif walking_towards == "npc2":
		walk_towards_npc2()
	elif walking_towards == "npc3":
		walk_towards_npc3()
	elif walking_towards == "npc4":
		walk_towards_npc4()
		
		
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
		#print("Position",position)
	else:
		direction = Vector2.ZERO

func _on_walk_timer_timeout():
	pass
	# Generate a new random direction
	#direction = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()/10
	
func walk_towards_npc():
	if npc != null and global_position.distance_to(npc.global_position) > conversation_distance_threshold:
		position += (npc.position - position)/100
		walking_towards = "npc"
	#elif is_conversation:
		#direction = Vector2.ZERO
		#print("starting conversation after walk")
		#npc2_area.start_conversation("Hi, whats your name?")
		#is_conversation = false
func walk_towards_npc1():
	if npc != null and global_position.distance_to(npc.global_position) > conversation_distance_threshold:
		position += (npc.position - position)/200
		walking_towards = "npc1"
		

func walk_towards_npc2():
	if npc2 != null and global_position.distance_to(npc2.global_position) > conversation_distance_threshold:
		position += (npc2.position - position)/200
		walking_towards = "npc2"
		
func walk_towards_npc3():
	if npc3 != null and global_position.distance_to(npc3.global_position) > conversation_distance_threshold:
		position += (npc3.position - position)/200
		walking_towards = "npc3"

func walk_towards_npc4():
	if npc4 != null and global_position.distance_to(npc4.global_position) > conversation_distance_threshold:
		position += (npc4.position - position)/200
		walking_towards = "npc4"


func _on_detection_area_body_entered(body):
	if body.name != self.name:
		close_npc_list.append(body.name)
		print(close_npc_list)
	


func _on_detection_area_body_exited(body):
	if body.name != self.name:
		close_npc_list.erase(body.name)
		print(close_npc_list)
		
func npc_movement(dir):
	print("Moving direction: ", dir)
	
	if dir == "move-right":
		print("Moving right")
		current_dir = "move-right"
		#play_anim(1)
		velocity.x = speed
		velocity.y = 0
	elif dir == "move-left":
		print("Moving left")		
		current_dir = "move-left"
		#play_anim(1)
		velocity.x = -speed
		velocity.y = 0
	elif dir == "move-down":
		print("Moving down")		
		current_dir = "move-down"
		#play_anim(1)
		velocity.x = 0
		velocity.y = speed
	elif dir == "move-up":
		print("Moving up")				
		current_dir = "move-up"
		#play_anim(1)
		velocity.x = 0
		velocity.y = -speed
	else:
		#play_anim(0)
		velocity.x = 0
		velocity.y = 0
	move_and_slide()
