extends Area2D



var httpRequest = HTTPRequest.new()
var dialogue_box = null
var json = JSON.new()
var npc = null
var npc2 = null
var dialogue = null
var is_conversation = true
var npc_area = null
var counter = 0

var speed = 200

func _ready():
	add_child(httpRequest)
	dialogue_box = get_node("../Dialogue")
	httpRequest.request_completed.connect(_on_request_completed)
	npc = get_node("/root/world/Npc")
	npc_area = get_node("/root/world/Npc/Area2D")
	npc2 = get_node("/root/world/Npc2")
	dialogue = get_node("../Dialogue")


func send_request(user_input: String):
	var headers = ["Content-Type: application/json"]
	
	var body = {
	"prompt": user_input
	}
	var body_text = JSON.stringify(body)  # use JSON.print() to convert dict to JSON string
	if user_input == "attack":
		print("moving to enemy")
		npc.start_attacking()
	elif user_input == "conversation":  # Add this line
		npc.start_walking_towards_npc()
	else:
		httpRequest.request("http://127.0.0.1:5000/generate", headers, HTTPClient.METHOD_POST, body_text)
	
	# Send the request


func _on_request_completed(result, response_code, headers, body):
	#var json = JSON.parse_string(body.get_string_from_utf8())
	var response = str_to_var(body.get_string_from_utf8())
	#var text = response["choices"][0]["text"].strip_edges()
	print(response)
	use_dialogue()
	dialogue_box.change("Dan", response)
	if is_conversation:
		await get_tree().create_timer(5).timeout
		npc_area.respond_to_conversation(response)
		counter = counter + 1
		print("Counter ", counter)
		#is_conversation = false

func  _input(event):
	if event.is_action_pressed("ui_accept") and len(get_overlapping_bodies()) > 0:
		use_dialogue()

func use_dialogue():
	if dialogue:
		dialogue.start("Dan")

func _on_body_exited(body):
	if body.name == "player":
		dialogue_box.hide_box()		

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




	

	
