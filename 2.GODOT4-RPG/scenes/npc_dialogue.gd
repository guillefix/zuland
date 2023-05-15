extends Area2D

var httpRequest = HTTPRequest.new()
var dialogue_box = null
var json = JSON.new()
var dialogue = null
var is_conversation = true
var counter = 0
var current_action = "idle"

var speed = 200

var close_npcs = []
#var NPC = preload("res://scenes/npc.gd").new()  # preload NPC script



func _ready():
	add_child(httpRequest)
	dialogue_box = get_node("../Dialogue")
	httpRequest.request_completed.connect(_on_request_completed)
	dialogue = get_node("../Dialogue")
#	generate_image(self.get_parent().description)		


func send_request(user_input: String):
	var headers = ["Content-Type: application/json"]
	var nearby_players = self.get_parent().close_npc_list
	print("action requested")
	
	#function to check nearby NPCs
	
	var body = {
		"npc_name": self.get_parent().name,
		"npc_desc": self.get_parent().description,
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

func generate_image(prompt: String):
	var headers = ["Content-Type: application/json"]
	print("generate image action requested")
	
	#function to check nearby NPCs
	
	var body = {
		"prompt": prompt
	}
	var body_text = JSON.stringify(body)  # use JSON.print() to convert dict to JSON string
	httpRequest.request("http://127.0.0.1:5000/t2i", headers, HTTPClient.METHOD_POST, body_text)

	
	# Send the request


func _on_request_completed(result, response_code, headers, body):
	#If Nill or null just wait*
	#var json = JSON.parse_string(body.get_string_from_utf8()
	var res = str_to_var(body.get_string_from_utf8())
	if res == null:
		self.send_request("did nothing")
		return
	if "generated_img" in res:
#		var preview : Texture = load(res["generated_img"])
#		self.get_parent().get_node("TextureRect").texture = load("res://generated/"+res["generated_img"])
		var img = Image.new()
		img.load("res://generated/"+res["generated_img"])
		var tex = ImageTexture.create_from_image(img)
#		if ResourceLoader.exists("res://generated/" + res["generated_img"]):
#		if FileAccess.file_exists("res://generated/" + res["generated_img"]):
#			print("File exists")
#		else:
#			print("File not found")
#		var tex = ResourceLoader.load("res://generated/" + res["generated_img"])
		self.get_parent().get_node("TextureRect").texture = tex		
#		self.get_parent().get_node("TextureRect").texture = load("res://generated/"+"v1_txt2img_bf4a3e3d-f260-11ed-a978-d03c1f36e4ac.png")		
		self.get_parent().get_node("TextureRect").set_scale(Vector2(0.1,0.1))
#		self.get_parent().get_node("TextureRect").texture = load("res://generated/"+"v1_txt2img_bf4a3e3d-f260-11ed-a978-d03c1f36e4ac.png")
		print("loaded "+"res://generated/"+res["generated_img"])
		self.send_request("Just generated image")
		return
	var response = JSON.parse_string(res)	
	
	#var text = response["choices"][0]["text"].strip_edges()
	print("Who?", self.get_parent().name)
	print("RESPONSE", response)
	self.get_parent().change_panel_text(response.action.thought)
	self.get_parent().change_emotion(response.action.feeling)
	#self.get_node("/root/world/info_box").get_node(self.get_parent().name).get_node("thought").text = response.action.thought

	if response.action.type == "walkTo":
		current_action = "walking"
		var location_name = response.action.where
		print("walking to " + location_name)
		self.get_parent().walk_towards(location_name)
		self.send_request("Just walked to " + location_name)
				
	elif response.action.type == "wait":
		print("WAITING")
		self.send_request("Just Waited")
								
	elif response.action.type == "move":
		var direction = response.action.direction
		self.get_parent().npc_movement("move-"+direction)
		self.send_request("Just moved "+direction)			
			
	elif response.action.type == "talkTo":
			self.get_parent().talk_to_npc(response.action.where, response.action.talking)
			self.send_request("Just talked to" + response.action.where + " about response.action.talking")
			
			
	

func  _input(event):
	if event.is_action_pressed("ui_accept") and len(get_overlapping_bodies()) > 0:
		#use_dialogue()
		pass
		

func start_conversation(from_npc: String, prompt :String):
	print("start conversation with prompt: ", prompt)
	send_request(from_npc + " said: " + prompt)	
		
#func respond_to_conversation(prompt :String):
#	print("start conversation with prompt: ", prompt)
#	send_request(prompt)
	#if is_conversation:
		#npc_area.start_conversation(prompt)
		#is_conversation = false		

func move_response():
	print("calling next action..")
	self.send_request("")
