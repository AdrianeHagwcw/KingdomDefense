extends Control

signal start_game

@onready var settings_panel = $SettingsPanel
@onready var credits_panel = $CreditsPanel


func _ready():
	# Hide panels first
	settings_panel.hide()
	credits_panel.hide()

	# Since your buttons are inside MainMenu/M/VB
	var container_path = "M/VB"

	var new_game_button = get_node_or_null(container_path + "/NewGame")
	var settings_button = get_node_or_null(container_path + "/Settings")
	var credits_button = get_node_or_null(container_path + "/Credits")
	var quit_button = get_node_or_null(container_path + "/Quit")

	if new_game_button:
		new_game_button.pressed.connect(_on_new_game_pressed)
	else:
		push_error("NewGame button not found at: " + container_path + "/NewGame")

	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)
	else:
		push_error("Settings button not found at: " + container_path + "/Settings")

	if credits_button:
		credits_button.pressed.connect(_on_credits_pressed)
	else:
		push_error("Credits button not found at: " + container_path + "/Credits")

	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
	else:
		push_error("Quit button not found at: " + container_path + "/Quit")


func _on_new_game_pressed():
	print("NEW GAME BUTTON PRESSED")
	start_game.emit()


func _on_settings_pressed():
	settings_panel.show()
	credits_panel.hide()


func _on_credits_pressed():
	credits_panel.show()
	settings_panel.hide()


func _on_quit_pressed():
	get_tree().quit()
