PROJECT(mycroft-gui-app)



SET(mycroft_gui_app_SRC
    main.cpp
    appsettings.cpp
    speechintent.cpp
)

if (CMAKE_SYSTEM_NAME STREQUAL "Android")
    set(mycroft_gui_app_EXTRA_LIBS
        Qt5::AndroidExtras
        Qt5::QuickControls2
        #NOTE: qtsvg is needed for android packaging to work
        Qt5::Svg
        Qt5::WebSockets
        OpenSSL::SSL
    )
else()
set(mycroft_gui_app_EXTRA_LIBS
        Qt5::Widgets
    )
endif()

qt5_add_resources(mycroft_gui_app_SRC
    qml.qrc
)

add_executable(mycroft-gui-app ${mycroft_gui_app_SRC})
target_link_libraries(mycroft-gui-app Qt5::Core Qt5::Quick Qt5::WebView ${mycroft_gui_app_EXTRA_LIBS})


install(TARGETS mycroft-gui-app ${INSTALL_TARGETS_DEFAULT_ARGS})
install( PROGRAMS ai.mycroft.gui-app.desktop DESTINATION  ${KDE_INSTALL_APPDIR} )

if (CMAKE_SYSTEM_NAME STREQUAL "Android")
    find_package(KF5Kirigami2 REQUIRED)
    kirigami_package_breeze_icons(ICONS help-hint configure media-playback-pause media-playback-start media-seek-forward media-seek-backward)
endif()


