extends CharacterBody2D


const speed = 100
var current_dir = "none"
var enemy_inattack_range = false
var enemy_attack_cooldown = true
var health = 100
var player_alive = true

func _on_http_request_request_completed(result, response_code, headers, body):
	var body_text = body.get_string_from_utf8()
	print("HTTP Response ---")
	print(body_text)

func _ready():
	$AnimatedSprite2D.play("front_idle")
	#var inputLine = get_node("/root/world/LineEdit")  # replace "World" with the actual path to the LineEdit node
	#print(inputLine)  # print the LineEdit node
	#print(inputLine.get_class())  # print the class of the LineEdit node
	#inputLine.text_submitted.connect(_on_text_entered)  # Use text_submitted signal instead
	#print(inputLine)


func _physics_process(delta):
	player_movement(delta)
	enemy_attack()
	
	if health <= 0:
		player_alive = false
		health = 0
		#print("player has been killed")
		#self.queue_free()
		

func player_movement(delta):
	
	if Input.is_action_pressed("ui_right"):
		current_dir = "right"
		play_anim(1)
		velocity.x = speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_left"):
		current_dir = "left"
		play_anim(1)
		velocity.x = -speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_down"):
		current_dir = "down"
		play_anim(1)
		velocity.x = 0
		velocity.y = speed
	elif Input.is_action_pressed("ui_up"):
		current_dir = "up"
		play_anim(1)
		velocity.x = 0
		velocity.y = -speed
	else:
		play_anim(0)
		velocity.x = 0
		velocity.y = 0
	
	move_and_slide()
	
func play_anim(movement):
	var dir = current_dir
	var anim = $AnimatedSprite2D
	
	if dir == "right":
		anim.flip_h = false
		if movement == 1:
			anim.play("side_walk")
		elif movement == 0:
			anim.play("side_idle")
	if dir == "left":
		anim.flip_h = true
		if movement == 1:
			anim.play("side_walk")
		elif movement == 0:
			anim.play("side_idle")
	if dir == "down":
		anim.flip_h = false
		if movement == 1:
			anim.play("front_walk")
		elif movement == 0:
			anim.play("front_idle")
	if dir == "up":
		anim.flip_h = false
		if movement == 1:
			anim.play("back_walk")
		elif movement == 0:
			anim.play("back_idle")
			
			


func _on_player_hitbox_body_entered(body):
	if body.has_method("enemy"):
		enemy_inattack_range = true


func _on_player_hitbox_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	if body.has_method("enemy"):
		enemy_inattack_range = false

func enemy_attack():
	if enemy_inattack_range and enemy_attack_cooldown == true:
		health = health - 20
		enemy_attack_cooldown = false
		$attack_cooldown.start()
		#print(health)
		#print("player took damage")

func player():
	pass

func _on_attack_cooldown_timeout():
	enemy_attack_cooldown = true
	


func _on_line_edit_text_submitted(new_text):
	print("Text entered on submitted: ", new_text)
	# assuming the NPC node is named "NPC" and is a sibling of the current node
	get_node("/root/world/Npc/action_area").send_request(new_text)	
	get_node("/root/world/Npc2/action_area").send_request(new_text)	
	get_node("/root/world/Npc3/action_area").send_request(new_text)	
	get_node("/root/world/Npc4/action_area").send_request(new_text)				

	
func _on_text_entered(new_text):
	print("Text entered: ", new_text)
	# assuming the NPC node is named "NPC" and is a sibling of the current node
	get_node("/root/world/Npc/action_area").send_request(new_text)	
	get_node("/root/world/Npc2/action_area").send_request(new_text)	
	get_node("/root/world/Npc3/action_area").send_request(new_text)	
	get_node("/root/world/Npc4/action_area").send_request(new_text)		
