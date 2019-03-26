include_directories("${CMAKE_CURRENT_BINARY_DIR}")

set(mycroftmark2_SRCS
    mycroftmark2.cpp
)

add_library(plasma_applet_mycroftmark2 MODULE ${mycroftmark2_SRCS})

kcoreaddons_desktop_to_json(plasma_applet_mycroftmark2 package/metadata.desktop)

target_link_libraries(plasma_applet_mycroftmark2
                      Qt5::Gui
                      KF5::Plasma
                      KF5::I18n
                      PW::KWorkspace)


install(TARGETS plasma_applet_mycroftmark2 DESTINATION ${KDE_INSTALL_PLUGINDIR}/plasma/applets)
#install(FILES plasma-mycroftmark2-default.desktop DESTINATION ${SERVICES_INSTALL_DIR})

plasma_install_package(package org.kde.mycroft.mark2)

