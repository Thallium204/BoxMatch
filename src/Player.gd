class_name Player
extends KinematicBody2D

enum ActionType{ATTACK, MOVE}
var ActionTypeColors = [Color.red, Color.blue]
enum DirectionType{ROOK, BISHOP}

const DETECTION_THRESHOLD = 4
const HEALTH_MAX = 3
var health:int = HEALTH_MAX
var direction_type_vectors = {
	DirectionType.ROOK:		[Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT],
	DirectionType.BISHOP:	[Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1), Vector2(-1, -1)],
}
var selector 
var rng = RandomNumberGenerator.new()

func get_class() -> String: return "Player"

func _ready():
	test_action()
	
func test_action():
	rng.randomize()
	var action_type = rng.randi_range(0, 1)
	var direction_type = rng.randi_range(0, 1)
	var number = rng.randi_range(1, 4)
	prepare_action(action_type, direction_type, number)

func prepare_action(action_type:int, direction_type:int, number:int):
	
	# Add Selector Node
	selector = Node2D.new()
	selector.name = "selector"
	selector.z_index = 1 
	add_child(selector)
	
	# Add Selectable children
	for vector_direction in direction_type_vectors[direction_type]:
		var vector_relative_position = vector_direction * 128 * number
		var is_targetable = (move_and_collide(vector_relative_position, true, true, true) == null)
		if is_targetable:
			var Selectable:TouchScreenButton = load("res://src/Selectable.tscn").instance()
			Selectable.get_node("sprTint").modulate = ActionTypeColors[action_type]
			Selectable.get_node("sprTint").modulate.a = 0.5
			Selectable.get_node("sprTint/Line2D").points = PoolVector2Array([Vector2.ZERO, -vector_relative_position])
			Selectable.connect("pressed", self, "execute_action", [action_type, vector_relative_position])
			Selectable.position = vector_relative_position
			selector.add_child(Selectable)
	
	# Retry random action if no valid options
	if selector.get_children().empty():
		selector.queue_free()
		test_action()

func execute_action(action_type:int, vector_relative_position:Vector2):
	
	# Delete selectables
	selector.queue_free()
	
	# Perform relevant action
	match action_type:
		ActionType.ATTACK:
			var object = get_object_at_position(position + vector_relative_position)
			if not object:
				continue
			# What are we attacking? 
			match object.get_class():
				"Player":
					var player:Player = object
					player.damage(1)
				"Crate":
					pass
		ActionType.MOVE:
			position += vector_relative_position
	
	test_action()

func damage(value:int):
	print(name, " took ", value, " damage ")
	health -= value
	if health <= 0:
		exhaust()

func exhaust():
	queue_free()

func get_object_at_position(given_position):
	var object_array:Array = get_tree().get_nodes_in_group("object")
	for object in object_array:
		if (object.position - given_position).length() <= DETECTION_THRESHOLD:
			return object
	return null
