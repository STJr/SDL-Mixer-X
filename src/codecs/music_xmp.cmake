option(USE_XMP         "Build with XMP library" ON)
if(USE_XMP AND NOT SDL_MIXER_CLEAR_FOR_ZLIB_LICENSE)
    option(USE_XMP_DYNAMIC "Use dynamical loading of XMP library" OFF)
    option(USE_XMP_LITE "Use the lite version of XMP library" OFF)

    set(USE_XMP_LITE_ENFORCE ${SDL_MIXER_CLEAR_FOR_ZLIB_LICENSE})

    if(USE_SYSTEM_AUDIO_LIBRARIES)
        if(USE_XMP_LITE OR USE_XMP_LITE_ENFORCE)
            find_package(XMPLite)
            message("XMP-Lite: [${XMPLITE_FOUND}] ${XMPLITE_INCLUDE_DIRS} ${XMPLITE_LIBRARIES}")
            if(USE_XMP_DYNAMIC)
                list(APPEND SDL_MIXER_DEFINITIONS -DXMP_DYNAMIC=\"${XMPLITE_DYNAMIC_LIBRARY}\")
                message("Dynamic XMP-Lite: ${XMPLITE_DYNAMIC_LIBRARY}")
            endif()
            set(XMP_INCLUDE_DIRS ${XMPLITE_INCLUDE_DIRS})
            set(XMP_LIBRARIES ${XMPLITE_LIBRARIES})
            set(XMP_FOUND ${XMPLITE_FOUND})
        else()
            find_package(XMP)
            message("XMP: [${XMP_FOUND}] ${XMP_INCLUDE_DIRS} ${XMP_LIBRARIES}")
            if(USE_XMP_DYNAMIC)
                list(APPEND SDL_MIXER_DEFINITIONS -DXMP_DYNAMIC=\"${XMP_DYNAMIC_LIBRARY}\")
                message("Dynamic XMP: ${XMP_DYNAMIC_LIBRARY}")
            endif()
        endif()

    else()
        if(WIN32)
            list(APPEND SDL_MIXER_DEFINITIONS -DBUILDING_STATIC)
        endif()
        if(USE_XMP_LITE OR USE_XMP_LITE_ENFORCE)
            if(MSVC)
                set(xmplib libxmp-lite-static)
            else()
                set(xmplib xmp-lite)
            endif()
        else()
            if(MSVC)
                set(xmplib libxmp-static)
            else()
                set(xmplib xmp)
            endif()
        endif()
        if(DOWNLOAD_AUDIO_CODECS_DEPENDENCY)
            set(XMP_LIBRARIES ${xmplib}${MIX_DEBUG_SUFFIX})
        else()
            find_library(XMP_LIBRARIES NAMES ${xmplib} libxmp
                         HINTS "${AUDIO_CODECS_INSTALL_PATH}/lib")
        endif()
        set(XMP_FOUND 1)
        set(XMP_INCLUDE_DIRS
            ${AUDIO_CODECS_PATH}/libxmp/include
            ${AUDIO_CODECS_INSTALL_PATH}/include/xmp
        )
    endif()

    if(XMP_FOUND)
        if(NOT USE_XMP_DYNAMIC)
            if(USE_XMP_LITE OR USE_XMP_LITE_ENFORCE)
                message("== using libXMP-Lite (MIT) ==")
                setLicense(LICENSE_MIT)
            else()
                message("== using libXMP (LGPL v2.1+) ==")
                setLicense(LICENSE_LGPL_2_1p)
            endif()
        endif()
        list(APPEND SDL_MIXER_DEFINITIONS -DMUSIC_MOD_XMP)
        list(APPEND SDL_MIXER_INCLUDE_PATHS ${XMP_INCLUDE_DIRS})
        if(NOT USE_SYSTEM_AUDIO_LIBRARIES OR NOT USE_XMP_DYNAMIC)
            list(APPEND SDLMixerX_LINK_LIBS ${XMP_LIBRARIES})
        endif()
        list(APPEND SDLMixerX_SOURCES
            ${CMAKE_CURRENT_LIST_DIR}/music_xmp.c
            ${CMAKE_CURRENT_LIST_DIR}/music_xmp.h
        )
    else()
        message("-- skipping XMP --")
    endif()
endif()
