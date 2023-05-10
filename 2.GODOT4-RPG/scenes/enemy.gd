extends CharacterBody2D

var speed = 100
var player_chase = false
var player = null

func _physics_process(delta):
	if player_chase:
		position += (player.position - position)/speed
		
		$AnimatedSprite2D.play("walk")
		
		if(player.position.x - position.x) < 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.play("idle")
		
func _on_detection_area_body_entered(body):
	player = body 
	player_chase = true
	
func _on_detection_area_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	player = null 
	player_chase = false
	



func _on_enemy_hitbox_body_entered(body):
	pass # Replace with function body.


func _on_enemy_hitbox_body_exited(body):
	pass # Replace with function body.
	
func enemy():
	pass
