extends Area2D

var httpRequest = HTTPRequest.new()
var dialogue_box = null
var json = JSON.new()
var npc = null
var npc2 = null
var npc3 = null
var npc4 = null
var dialogue = null
var is_conversation = true
var npc_area = null
var npc_area3 = null
var npc_area4 = null
var counter = 0
var current_action = "idle"

var speed = 200

var close_npcs = []
#var NPC = preload("res://scenes/npc.gd").new()  # preload NPC script


func _ready():
	add_child(httpRequest)
	dialogue_box = get_node("../Dialogue")
	httpRequest.request_completed.connect(_on_request_completed)
	npc = get_node("/root/world/Npc")
	npc2 = get_node("/root/world/Npc2")
	npc3 = get_node("/root/world/Npc3")
	npc4 = get_node("/root/world/Npc4")
	npc_area = get_node("/root/world/Npc/Area2D")
	npc_area3 = get_node("/root/world/Npc3/Area2D")	
	npc_area4 = get_node("/root/world/Npc4/Area2D")	
	dialogue = get_node("../Dialogue")


func send_request(user_input: String):
	var headers = ["Content-Type: application/json"]
	var nearby_players = self.get_parent().close_npc_list
	print("action requested")
	
	#function to check nearby NPCs
	
	var body = {
		"npc": self.get_parent().name,
		"location": "park",
		"activity": current_action,
		"nearby_players": nearby_players,
		"inventory": [],
		"message": user_input,
		"funds": 100
	}
	var body_text = JSON.stringify(body)  # use JSON.print() to convert dict to JSON string
	if user_input == "attack":
		print("moving to enemy")
		self.get_parent().start_attacking()
	
	elif user_input == "conversation":  # Add this line
		self.get_parent().start_walking_towards_npc()
	else:
		httpRequest.request("http://127.0.0.1:5000/chat", headers, HTTPClient.METHOD_POST, body_text)

	
	# Send the request


func _on_request_completed(result, response_code, headers, body):
	#var json = JSON.parse_string(body.get_string_from_utf8()
	var response = JSON.parse_string(str_to_var(body.get_string_from_utf8()))
	#var text = response["choices"][0]["text"].strip_edges()
	print("RESPONSE", response)

	#print("RESPONSE 1", response.action)
	#print("RESPONSE 2", response.direction)
	#print("RESPONSE 3", response.where)
	var npc_names = ["Alice", "Bob", "Charlie","Shoopkeeper"]
	var npc_codex = ["npc", "npc2", "npc3", "npc4"]
	if response.action.type == "walkTo":
		current_action = "walking"
		if response.action.where == "npc1":
			print("walking to npc1")
			self.get_parent().walk_towards_npc1()
			self.send_request("Just walked to npc1")
		elif response.action.where == "npc2":
			print("walking to npc2")
			self.get_parent().walk_towards_npc2()			
			self.send_request("Just walked to npc2")
		elif response.action.where == "npc3":
			print("walking to npc3")
			self.get_parent().walk_towards_npc3()
			self.send_request("Just walked to npc3")
		elif response.action.where == "npc4":
			print("walking to npc4")	
			self.get_parent().walk_towards_npc4()
			self.send_request("Just walked to npc4")			
	elif response.action.type == "wait":
		print("WAITING")
		self.send_request("Just Waited")						
	elif response.action.type == "move":
		if response.action.direction == "right":
			self.get_parent().npc_movement("move-right")
			self.send_request("Just moved right")			
		elif response.action.direction == "left":
			self.get_parent().npc_movement("move-left")
			self.send_request("Just moved left")						
		elif response.action.direction == "up":
			self.get_parent().npc_movement("move-up")
			self.send_request("Just moved up")						
		elif response.action.direction == "down":
			self.get_parent().npc_movement("move-down")
			self.send_request("Just moved down")						
	
	
	



	
	#use_dialogue()


	#dialogue_box.change("Dan", response)
	#if is_conversation:
		#await get_tree().create_timer(5).timeout
		#npc_area.respond_to_conversation(response)
		#counter = counter + 1
		#print("Counter ", counter)
		#is_conversation = false

func  _input(event):
	if event.is_action_pressed("ui_accept") and len(get_overlapping_bodies()) > 0:
		#use_dialogue()
		pass

func use_dialogue():
	if dialogue:
		dialogue.start("Dan")

func _on_body_exited(body):
	if body.name == "player":
		dialogue_box.hide_box()		
	#if body.get_script() == NPC:  # check if the body is an instance of NPC, replace NPC with your NPC class

		

func start_conversation(prompt :String):
	print("start conversation with prompt:", prompt)
	dialogue.start("Dan")
	send_request(prompt)
		
func respond_to_conversation(prompt :String):
	print("start conversation with prompt:", prompt)
	dialogue.start("Dan")
	send_request(prompt)
	#if is_conversation:
		#npc_area.start_conversation(prompt)
		#is_conversation = false		

func move_response():
	print("calling next action..")
	self.send_request("")
