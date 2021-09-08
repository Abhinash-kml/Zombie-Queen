PROJECT = zombie_plague_amxx_i386.so

INCLUDE = -I. \
	-IHLSDK -IMETAMOD

OBJECTS = amxxmodule.cpp \
	Zombie_Plague.cpp

FLAGS = -DNDEBUG -O2 -funroll-loops -fomit-frame-pointer -pipe \
    -fvisibility=hidden -fvisibility-inlines-hidden -DLINUX \
    -shared -m32 -lm -ldl -DPAWN_CELL_SIZE=32 -DJIT -DASM32 \
    -DHAVE_STDINT_H -fno-strict-aliasing -fno-exceptions \
    -fno-rtti -s -Wno-delete-non-virtual-dtor -static-libgcc \
    -D_snprintf=snprintf -D_strcpy=strcpy -D_strcat=strcat \
    -D_snprintf_s=snprintf -D_strncpy=strncpy -D_strncat=strncat \
    -D_stricmp=strcasecmp -D_strcmp=strcmp -D_strncmp=strncmp \
    -D_strnicmp=strncasecmp -Dstrnicmp=strncasecmp \
    -Dstricmp=strcasecmp -fpermissive

default:
	gcc $(OBJECTS) $(FLAGS) $(INCLUDE) -o $(PROJECT)
