extends Node

func wait(delay: float) -> Signal:
	return get_tree().create_timer(delay).timeout
