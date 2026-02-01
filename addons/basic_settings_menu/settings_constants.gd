# Purpose: This Resource is now a PURE DATA container.
# It holds the structure and default values of your settings.
# All logic has been moved to SettingsData and SettingsApplier.

class_name SettingsConstants extends Resource

const LOCALES = {
	"en": "English",
	"fr": "French / Français",
	"es": "Spanish / Español",
	"de": "German / Deutsch",
	"it": "Italian / Italiano",
	"br": "Portuguese / Português (BR)",
	"pt": "Portuguese / Português (PT)",
	"ru": "Russian / Русский",
	"el": "Greek / Ελληνικά",
	"tr": "Turkish / Türkçe",
	"da": "Danish / Dansk",
	"nb": "Norwegian (NB) / Norsk Bokmål",
	"sv": "Swedish / Svenska",
	"nl": "Dutch / Nederlands",
	"pl": "Polish / Polski",
	"fi": "Finnish / Suomi",
	"ja": "Japanese / 日本語",
	"zh": "Simplified Chinese / 简体中文",
	"lzh": "Traditional Chinese / 繁体中文",
	"ko": "Korean / 한국어",
	"cs": "Czech / Čeština",
	"hu": "Hungarian / Magyar",
	"ro": "Romanian / Română",
	"th": "Thai / ภาษาไทย",
	"bg": "Bulgarian / Български",
	"he": "Hebrew / עברית",
	"ar": "Arabic / العربية",
	"bs": "Bosnian"
}

const RESOLUTIONS_ARRAY : Array[Vector2i] = [
	Vector2i(640, 360),
	Vector2i(960, 540),
	Vector2i(1024, 576),
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2048, 1152),
	Vector2i(2560, 1440),
	Vector2i(3200, 1800),
	Vector2i(3840, 2160),
]
