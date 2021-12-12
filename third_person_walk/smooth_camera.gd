extends Camera

export var target_path : NodePath = "../.." setget set_target_path
export var smoothing := 0.2


var _target : Spatial

func _ready() -> void:
	_target = get_node(target_path)


func _physics_process(_delta: float) -> void:
	transform = transform.interpolate_with(_target.global_transform, smoothing)
#	var pos_delta = _target.global_transform.origin - translation
#	translation += pos_delta * smoothing
#	var rot_delta = _target.global_transform.basis.get_euler() - rotation
#	rotation += rot_delta * smoothing



func set_target_path(new: NodePath) -> void:
	target_path = new
	_target = get_node(target_path)
