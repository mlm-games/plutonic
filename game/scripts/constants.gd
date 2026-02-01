class_name C extends Node # Constants

enum BusNames {
	Master,
	Music,
	Sfx,
}

const SCREENS = {
	CREDITS = "uid://bq0gelfcjnqvg",
	SETTINGS = "uid://dp42fom7cc3n0",
	MENU = "uid://ddl5roo03rvdl",
	END = "uid://o7bist5hmyv6",
	GAME = "res://game/scenes/game/game_world.tscn",
}

const RESOURCES = {
	SHADERS = {},
	SPAWNS = {}
}

const PATHS = {}

const GAME_VERSION := "1.0.0"

# Planet merge order (index = tier, 0-10)
enum PlanetType {
	PLUTO = 0,
	MOON = 1,
	MERCURY = 2,
	MARS = 3,
	VENUS = 4,
	EARTH = 5,
	NEPTUNE = 6,
	URANUS = 7,
	SATURN = 8,
	JUPITER = 9,
	SUN = 10,
}

# Planet radii (collision/visual size in pixels)
const PLANET_RADII: Array[float] = [
	20.0, # Pluto
	32.0, # Moon
	44.0, # Mercury
	58.0, # Mars
	74.0, # Venus
	92.0, # Earth
	112.0, # Neptune
	134.0, # Uranus
	158.0, # Saturn
	184.0, # Jupiter
	220.0, # Sun
]

const PLANET_TEXTURES: Array[String] = [
	"res://game/assets/svg/planets/pluto.svg",
	"res://game/assets/svg/planets/moon.svg",
	"res://game/assets/svg/planets/mercury.svg",
	"res://game/assets/svg/planets/mars.svg",
	"res://game/assets/svg/planets/venus.svg",
	"res://game/assets/svg/planets/earth.svg",
	"res://game/assets/svg/planets/neptune.svg",
	"res://game/assets/svg/planets/uranus.svg",
	"res://game/assets/svg/planets/saturn.svg",
	"res://game/assets/svg/planets/jupiter.svg",
	"res://game/assets/svg/planets/sun.svg",
]

const PLANET_NAMES: Array[String] = [
	"Pluto", "Moon", "Mercury", "Mars", "Venus",
	"Earth", "Neptune", "Uranus", "Saturn", "Jupiter", "Sun"
]

# for merging to this tier
const PLANET_SCORES: Array[int] = [
	0, # Pluto (spawn, so no score)
	10, # Moon
	20, # Mercury
	40, # Mars
	80, # Venus
	160, # Earth
	320, # Neptune
	640, # Uranus
	1280, # Saturn
	2560, # Jupiter
	5120, # Sun
]

const GRAVITY_STRENGTH := 1000.0
const SHOOT_FORCE := 600.0
const MAX_SHOOT_FORCE := 1200.0
const PLANET_DENSITY := 1.0
const PLANET_FRICTION := 0.3
const PLANET_BOUNCE := 0.2

const BUBBLE_RADIUS := 400.0
const BUBBLE_CENTER := Vector2(540, 712)

const GRACE_PERIOD := 1.5 # Seconds before game over triggers
const BOUNDARY_CHECK_MARGIN := 10.0 # Pixels outside bubble before warning

const MAX_SPAWN_TIER := 4

const EYE_LOOK_SPEED := 3.0
const EYE_BLINK_INTERVAL_MIN := 2.0
const EYE_BLINK_INTERVAL_MAX := 5.0
const EYE_BLINK_DURATION := 0.15

const SAVE_FILE := "user://plutonic_save.json"
