#if defined _amx_settings_api_included
  #endinput
#endif
#define _amx_settings_api_included

#if AMXX_VERSION_NUM >= 175
	#pragma reqlib SettingsAPI
	#if !defined AMXMODX_NOAUTOLOAD
		#pragma loadlib SettingsAPI
	#endif
#else
	#pragma library SettingsAPI
#endif

native AmxLoadStringArray(const filename[], const section[], const key[], Array:array_handle)
native AmxSaveStringArray(const filename[], const section[], const key[], Array:array_handle)
native AmxLoadIntArray(const filename[], const section[], const key[], Array:array_handle)
native AmxSaveIntArray(const filename[], const section[], const key[], Array:array_handle)
native AmxLoadFloatArray(const filename[], const section[], const key[], Array:array_handle)
native AmxSaveFloatArray(const filename[], const section[], const key[], Array:array_handle)
native AmxLoadString(const filename[], const section[], const key[], setting_string[], len)
native AmxSaveString(const filename[], const section[], const key[], const setting_string[])
native AmxLoadInt(const filename[], const section[], const key[], &integer_value)
native AmxSaveInt(const filename[], const section[], const key[], integer_value)
native AmxLoadFloat(const filename[], const section[], const key[], &Float:float_value)
native AmxSaveFloat(const filename[], const section[], const key[], Float:float_value)
