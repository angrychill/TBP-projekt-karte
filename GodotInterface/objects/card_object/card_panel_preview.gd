extends PanelContainer
class_name CardPanelPreview

signal drag_completed(data : CardPanelPreview, success : bool)

@export var card_data : CardData
@export var label_up : Label
@export var label_down : Label
@export var label_mid : Label

var tween : Tween

#func _init(data : CardData) -> void:
	#card_data = data

func _ready() -> void:
	pass

	label_down.text = str(card_data.value)
	label_up.text = str(card_data.value)
	label_mid.text = str(card_data.suit)

func _input(event: InputEvent) -> void:
	if event.is_action_released("click"):
		self.queue_free()

func _process(delta: float) -> void:
	var mouse_pos : Vector2 = get_global_mouse_position()
	var minsize : Vector2 = get_combined_minimum_size()
	var offset : Vector2 = Vector2(minsize.x/2, minsize.y/2)
	
	if tween:
		tween.kill()
	tween = create_tween()
	#tween.set_ease(Tween.EASE_IN)
	#tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "global_position", mouse_pos, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
	
	pass

func _exit_tree() -> void:
	print("drag completed!")
	drag_completed.emit(self)
