extends PanelContainer
class_name CardReceiver

@export var capacity : int = 1
@export var capacity_parent : Node

@export var can_receive : bool = true

@export var card_holding = null

const CARD_PANEL = preload("res://objects/card_object/card_panel.tscn")
