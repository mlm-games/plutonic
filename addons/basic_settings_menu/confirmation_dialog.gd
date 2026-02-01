class_name SettingConfirmationDialog extends ConfirmationDialog

@onready var countdown_timer: Timer = %CountdownTimer

var _base_message: String = "Keep these settings?\nReverting in %d seconds."
var _is_active := false

func _ready() -> void:
	get_cancel_button().pressed.connect(_on_no_button_pressed)
	get_ok_button().pressed.connect(_on_yes_button_pressed)

func _process(delta: float) -> void:
	if not _is_active: return
	# Update the countdown text in the message
	var time_left := int(ceil(countdown_timer.time_left))
	dialog_text = _base_message % time_left

func start(message_template: String, duration: float) -> void:
	_base_message = message_template
	countdown_timer.wait_time = duration
	countdown_timer.start()
	_is_active = true
	show()
	get_ok_button().grab_focus()

func _stop() -> void:
	if countdown_timer.is_stopped(): return
	countdown_timer.stop()
	_is_active = false
	hide()

func _on_yes_button_pressed() -> void:
	_stop()

func _on_no_button_pressed() -> void:
	_stop()

func _on_countdown_timer_timeout() -> void:
	# If the timer runs out, it's the same as pressing "No".
	_stop()
	canceled.emit()
