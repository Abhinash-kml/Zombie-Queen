#if defined _tagsapi_included
	#endinput
#endif
#define _tagsapi_included

#pragma reqlib TagsApi
#if !defined AMXMODX_NOAUTOLOAD
	#pragma loadlib TagsApi
#endif

native get_user_chat_tag(id, tag[], maxlen);
