add_definitions(-DTRANSLATION_DOMAIN=\"plasma_applet_org.kde.mycroft.launcher\")

set(launcherapplet_SRCS
    launcherapplet.cpp
    applicationsmodel.cpp
)

add_library(plasma_applet_mycroft_launcher MODULE ${launcherapplet_SRCS})

kcoreaddons_desktop_to_json(plasma_applet_mycroft_launcher package/metadata.desktop)

target_link_libraries(plasma_applet_mycroft_launcher
                      Qt5::Qml
                      KF5::Service
                      #KF5::I18n
                      KF5::KIOWidgets # for KRun
                      KF5::Plasma)

install(TARGETS plasma_applet_mycroft_launcher DESTINATION ${KDE_INSTALL_PLUGINDIR}/plasma/applets)

plasma_install_package(package org.kde.mycroft.launcher)
