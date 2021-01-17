class_name Player
extends KinematicBody2D

enum ActionType{ATTACK, MOVE}
var ActionTypeColors = [Color.red, Color.blue]
enum DirectionType{ROOK, BISHOP}



var direction_type_vectors = {
	DirectionType.ROOK:		[Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT],
	DirectionType.BISHOP:	[Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1), Vector2(-1, -1)],
}
var selector 
var rng = RandomNumberGenerator.new()

func _ready():
	test_action()
	
func test_action():
	rng.randomize()
	var action_type = rng.randi_range(0, 1)
	var direction_type = rng.randi_range(0, 1)
	var number = rng.randi_range(1, 4)
	prepare_action(action_type, direction_type, number)

func prepare_action(action_type:int, direction_type:int, number:int):
	
	selector = Node2D.new()
	add_child(selector)
	
	for vector_direction in direction_type_vectors[direction_type]:
		var vector_relative_position = vector_direction * 128 * number
		var is_targetable = (move_and_collide(vector_relative_position, true, true, true) == null)
		if is_targetable:
			var Selectable:TouchScreenButton = load("res://src/Selectable.tscn").instance()
			Selectable.get_node("sprTint").modulate = ActionTypeColors[action_type]
			Selectable.connect("pressed", self, "execute_action", [action_type, vector_relative_position])
			Selectable.position = vector_relative_position
			selector.add_child(Selectable)
	
	if selector.get_children().empty():
		selector.queue_free()
		test_action()

func execute_action(action_type:int, vector_relative_position:Vector2):
	selector.queue_free()
	
	match action_type:
		ActionType.ATTACK:
			pass
		ActionType.MOVE:
			position += vector_relative_position
	
	test_action()
