extends Control

signal start_game_pressed
signal restart_game_pressed

var main_panel: Control
var about_panel: Control
var credits_panel: Control
var game_over_panel: Control

var start_button: BaseButton
var about_button: BaseButton
var credits_button: BaseButton
var quit_button: BaseButton

var about_back_button: BaseButton
var credits_back_button: BaseButton

var restart_button: BaseButton
var game_over_quit_button: BaseButton


func _ready():
	get_menu_nodes()
	make_labels_ignore_mouse()
	show_main_menu()
	connect_buttons()


func get_menu_nodes():
	main_panel = get_node_or_null("MainPanel")
	about_panel = get_node_or_null("AboutPanel")
	credits_panel = get_node_or_null("CreditsPanel")
	game_over_panel = get_node_or_null("GameOverPanel")

	start_button = get_node_or_null("MainPanel/VB/StartGame")
	about_button = get_node_or_null("MainPanel/VB/About")
	credits_button = get_node_or_null("MainPanel/VB/Credits")
	quit_button = get_node_or_null("MainPanel/VB/Quit")

	if about_panel != null:
		about_back_button = about_panel.find_child("BackButton", true, false) as BaseButton

	if credits_panel != null:
		credits_back_button = credits_panel.find_child("BackButton", true, false) as BaseButton

	if game_over_panel != null:
		restart_button = game_over_panel.find_child("RestartButton", true, false) as BaseButton
		game_over_quit_button = game_over_panel.find_child("QuitButton", true, false) as BaseButton


func connect_buttons():
	connect_button(start_button, _on_start_button_pressed, "StartGame")
	connect_button(about_button, _on_about_button_pressed, "About")
	connect_button(credits_button, _on_credits_button_pressed, "Credits")
	connect_button(quit_button, _on_quit_button_pressed, "Quit")

	connect_button(about_back_button, _on_about_back_button_pressed, "AboutPanel BackButton")
	connect_button(credits_back_button, _on_credits_back_button_pressed, "CreditsPanel BackButton")

	connect_button(restart_button, _on_restart_button_pressed, "RestartButton")
	connect_button(game_over_quit_button, _on_quit_button_pressed, "GameOver QuitButton")


func connect_button(button: BaseButton, target_function: Callable, button_name: String):
	if button == null:
		print("ERROR: Button not found or not a real button: ", button_name)
		return

	button.pressed.connect(target_function)


func make_labels_ignore_mouse():
	var labels = find_children("*", "Label", true, false)

	for label in labels:
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE


func show_main_menu():
	show()

	if main_panel != null:
		main_panel.show()

	if about_panel != null:
		about_panel.hide()

	if credits_panel != null:
		credits_panel.hide()

	if game_over_panel != null:
		game_over_panel.hide()


func show_game_over():
	show()

	if main_panel != null:
		main_panel.hide()

	if about_panel != null:
		about_panel.hide()

	if credits_panel != null:
		credits_panel.hide()

	if game_over_panel != null:
		game_over_panel.show()


func _on_start_button_pressed():
	hide()
	start_game_pressed.emit()


func _on_about_button_pressed():
	if main_panel != null:
		main_panel.hide()

	if about_panel != null:
		about_panel.show()

	if credits_panel != null:
		credits_panel.hide()

	if game_over_panel != null:
		game_over_panel.hide()


func _on_credits_button_pressed():
	if main_panel != null:
		main_panel.hide()

	if about_panel != null:
		about_panel.hide()

	if credits_panel != null:
		credits_panel.show()

	if game_over_panel != null:
		game_over_panel.hide()


func _on_about_back_button_pressed():
	show_main_menu()


func _on_credits_back_button_pressed():
	show_main_menu()


func _on_restart_button_pressed():
	hide()
	restart_game_pressed.emit()


func _on_quit_button_pressed():
	get_tree().quit()
