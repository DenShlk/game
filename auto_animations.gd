@tool
extends Sprite2D

@export var params: Array[Dictionary] = []
@export var animation_player: AnimationPlayer = null
@export var auto_player: bool = true

class AnimationParams:
	var name: String
	var length: float
	var frames: int
	
	func _init(d: Dictionary):
		assert(d.has('name'), "doesn't have 'name' key: %s" % d)
		assert(d.has('length'), "doesn't have 'length' key: %s" % d)
		assert(d.has('frames'), "doesn't have 'frames' key: %s" % d)
		assert(d.size() == 3, "redudant keys: %s" % d)
		
		self.name = d['name']
		self.length = d['length']
		self.frames = d['frames']

func _get_tool_buttons() -> Array:
	return [generate_animations, add_animation_param]

func add_animation_param():
	if (self.params.is_read_only()):
		self.params = []

	self.params.append(make_default_param_dict(self.params.size()))
	notify_property_list_changed()
	print(self.params)
	
func generate_animations():
	print('validating params...')
	var anim_params = take_params_from_input()
	
	print('generating...')
	var player = find_player()
	var library = find_library(player)
	for i in range(anim_params.size()):
		var param = anim_params[i]
		if not library.has_animation(param.name):
			library.add_animation(param.name, Animation.new())
		generate_animation(i, param, library.get_animation(param.name))
		print('added animation: ', param.name)
	
func generate_animation(idx: int, param: AnimationParams, animation: Animation):
	var path: String = '.:frame_coords'
	if animation.find_track(path, Animation.TYPE_VALUE) != -1:
		return
		
	animation.length = param.length
	
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, path)
	animation.track_set_interpolation_type(track_index, Animation.INTERPOLATION_LINEAR)

	animation.track_insert_key(track_index, 0.0, Vector2i(0, idx))
	animation.track_insert_key(track_index, animation.length, Vector2i(param.frames, idx))

	return animation
	
func find_player() -> AnimationPlayer:
	if animation_player != null:
		return animation_player
	if !auto_player:
		assert(false, 'Animation Player not given!')
		
	var tmp_player = find_child("AutoAnimationPlayer", false)
	if tmp_player == null:
		tmp_player = AnimationPlayer.new()
		tmp_player.name = "AutoAnimationPlayer"
		add_child(tmp_player)
		tmp_player.set_owner(get_tree().edited_scene_root)
		print('created animation player')
	return tmp_player
	
func find_library(player: AnimationPlayer) -> AnimationLibrary:
	if not player.has_animation_library('auto'):
		player.add_animation_library('auto', AnimationLibrary.new())
		print('created animation library')
		
	return player.get_animation_library('auto')

func take_params_from_input() -> Array[AnimationParams]:
	var result: Array[AnimationParams] = []
	for i in range(self.vframes):
		if i < self.params.size():
			result.append(AnimationParams.new(self.params[i]))
		else:
			result.append(AnimationParams.new(make_default_param_dict(i)))
	return result

func make_default_param_dict(idx) -> Dictionary:
	return {
		'name': "auto_%d" % idx,
		'length': 1.0,
		'frames': self.hframes,
	}
