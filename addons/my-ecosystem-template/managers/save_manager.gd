## A helper class for saving and loading game data.
##[br][br]
## Provides simple static functions to save and load a [Dictionary] of game data
## to a file in the [code]user://[/code] directory. Includes basic encryption
## and an auto-save function with a backup mechanism.
class_name SaveManager
extends RefCounted

## The path to the main save file.
const SAVE_PATH = "user://savegame.dat"
## The password for encryption.
##[br]
## @deprecated: Using a hardcoded password is NOT secure for a released game. This is for demonstration only.
const ENCRYPTION_KEY = "your_password"


## Saves game data to an encrypted file.
##[br][br]
## [color=yellow]Warning:[/color] Using a hardcoded password as the [code]ENCRYPTION_KEY[/code] is
## insecure and easily reversible. For a production game, consider generating a unique
## key per user or using a more robust encryption solution.
##[br][br]
## [param data]: The [Dictionary] containing the game data to save.
##[br]
## Returns [code]true[/code] on success, [code]false[/code] on failure.
static func save_game(data: Dictionary) -> bool:
	var file = FileAccess.open_encrypted_with_pass(SAVE_PATH, FileAccess.WRITE, ENCRYPTION_KEY)
	if not file:
		push_error("SaveManager: Failed to open save file for writing.")
		return false
	
	file.store_var(data)
	file.close()
	return true


## Loads game data from an encrypted file.
##[br][br]
## If the save file does not exist or fails to open, it returns an empty [Dictionary].
##[br]
## Returns: The loaded [Dictionary], or an empty one if no save is found.
static func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	
	var file = FileAccess.open_encrypted_with_pass(SAVE_PATH, FileAccess.READ, ENCRYPTION_KEY)
	if not file:
		push_error("SaveManager: Failed to open save file for reading. It might be corrupt or the key is wrong.")
		return {}
	
	var data = file.get_var()
	file.close()
	return data if data is Dictionary else {}


## Saves the game and creates a backup of the previous save file.
##[br][br]
## Before saving, it renames the existing save file to "[code]savegame.dat.bak[/code]".
##[br]
## This provides a simple way to recover data if the save process is interrupted.
##[br]
## [param data]: The [Dictionary] of game data to save.
static func auto_save(data: Dictionary) -> void:
	if FileAccess.file_exists(SAVE_PATH):
		# Create a backup of the existing save file.
		var dir = DirAccess.open("user://")
		dir.copy(SAVE_PATH, SAVE_PATH + ".bak")
	
	save_game(data)
