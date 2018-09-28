set(mycroftpanel_SRCS
    mycroftpanel.cpp
)

add_library(plasma_applet_mycroftpanel MODULE ${mycroftpanel_SRCS})

kcoreaddons_desktop_to_json(plasma_applet_mycroftpanel package/metadata.desktop)

target_link_libraries(plasma_applet_mycroftpanel
                      Qt5::Gui
                      KF5::Plasma
                      KF5::I18n
                      KF5::WindowSystem)


install(TARGETS plasma_applet_mycroftpanel DESTINATION ${KDE_INSTALL_PLUGINDIR}/plasma/applets)
#install(FILES plasma-mycroftpanel-default.desktop DESTINATION ${SERVICES_INSTALL_DIR})

plasma_install_package(package org.kde.mycroft.panel)

