option(USE_MP3_MAD      "Build with MAD MP3 codec" ON)
option(USE_MP3_MAD_GPL_DITHERING "Enable GPL-Licensed dithering functions for MAD library" OFF)

if(USE_MP3_MAD AND NOT SDL_MIXER_CLEAR_FOR_ZLIB_LICENSE AND NOT SDL_MIXER_CLEAR_FOR_LGPL_LICENSE)
    if(USE_SYSTEM_AUDIO_LIBRARIES)
        find_package(MAD QUIET)
        message("MAD: [${MAD_FOUND}] ${MAD_INCLUDE_DIRS} ${MAD_LIBRARIES}")
    else()
        if(DOWNLOAD_AUDIO_CODECS_DEPENDENCY)
            set(MAD_LIBRARIES mad${MIX_DEBUG_SUFFIX})
        else()
            find_library(MAD_LIBRARIES NAMES mad
                         HINTS "${AUDIO_CODECS_INSTALL_PATH}/lib")
        endif()
        set(MAD_FOUND 1)
        set(MAD_INCLUDE_DIRS ${AUDIO_CODECS_PATH}/libmad/include)
    endif()

    if(MAD_FOUND)
        message("== using MAD (GPLv2+) ==")
        setLicense(LICENSE_GPL_2p)
        list(APPEND SDL_MIXER_DEFINITIONS -DMUSIC_MP3_MAD)
        if(USE_MP3_MAD_GPL_DITHERING)
            list(APPEND SDL_MIXER_DEFINITIONS -DMUSIC_MP3_MAD_GPL_DITHERING)
        endif()
        list(APPEND SDLMixerX_LINK_LIBS ${MAD_LIBRARIES})
        list(APPEND SDL_MIXER_INCLUDE_PATHS ${MAD_INCLUDE_DIRS})

        list(APPEND SDLMixerX_SOURCES
            ${CMAKE_CURRENT_LIST_DIR}/music_mad.c
            ${CMAKE_CURRENT_LIST_DIR}/music_mad.h
        )

        if(USE_MP3_MAD_GPL_DITHERING)
            message(WARNING "*** Using GPL libmad and MP3 dithering routines, this build of SDL_mixer is now under the GPL")
        endif()
    else()
        message("-- skipping MAD --")
    endif()
endif()
