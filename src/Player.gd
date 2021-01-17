class_name Player
extends KinematicBody2D

enum ActionType{ATTACK,MOVE}
enum DirectionType{ROOK,BISHOP}

var directions = {
		DirectionType.ROOK:		[Vector2(1,0),Vector2(-1,0),Vector2(0,1),Vector2(0,-1)],
		DirectionType.BISHOP:	[Vector2(1,1),Vector2(1,-1),Vector2(-1,1),Vector2(-1,-1)]
		}

var tile_scale := 1
var selector_parent
var rng = RandomNumberGenerator.new()
var health = 3


func _ready():
	tile_scale = 4
	$labelHealth.text = str(health)
	test_action()

func snap_to_tilemap():
	position = Vector2( 16+stepify(position.x-16,32) , 16+stepify(position.y-16,32) )

func test_action():
	rng.randomize()
	var action_type = rng.randi_range(0,1)
	var direction_type = rng.randi_range(0,1)
	var number = rng.randi_range(1,4)
	prepare_action(action_type,direction_type,number)

func prepare_action(action_type:int,direction_type:int,number:int):
	
	selector_parent = Node2D.new()
	selector_parent.show_behind_parent = true
	add_child(selector_parent)
	for vector_direction in directions[direction_type]:
		var relative_vector = vector_direction*32*number
		var is_clear = (null == move_and_collide(relative_vector*tile_scale,true,true,true))
		yield(get_tree().create_timer(0.0), "timeout")
		if is_clear:
			var action_selector = load("res://src/ActionSelect.tscn").instance()
			action_selector.initialise(action_type,relative_vector)
			action_selector.position = relative_vector
			selector_parent.add_child(action_selector)
	# Check if any moves are posible
	if selector_parent.get_children().empty():
		selector_parent.queue_free()
		test_action()
	
	return

func execute_action(action_type:int,relative_vector:Vector2):
	# Delete selectors
	selector_parent.queue_free()
	
	match action_type:
		
		ActionType.ATTACK:
			
			var players = get_tree().get_nodes_in_group("player")
			for player in players:
				if (player.position-(position+relative_vector)).length() <= 4:
					player.damage(1)
			test_action()
		
		ActionType.MOVE:
			
			position += relative_vector
			test_action()
	
	snap_to_tilemap()

func damage(damage_value):
	health -= damage_value
	if health <= 0:
		kill_self()
	$labelHealth.text = str(health)

func kill_self():
	queue_free()


