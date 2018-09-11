# Set minimum CMake version (required for CMake 3.0 or later)
cmake_minimum_required(VERSION 2.8.12)
 
set(QT_MIN_VERSION "5.9.0")
set(KF5_MIN_VERSION "5.0.0")
 
PROJECT(mycroft-gui)

# Use Extra CMake Modules (ECM) for common functionality.
# See http://api.kde.org/ecm/manual/ecm.7.html
# and http://api.kde.org/ecm/manual/ecm-kde-modules.7.html
IF(POLICY CMP0063)
    CMAKE_POLICY(SET CMP0063 NEW)
ENDIF(POLICY CMP0063)

find_package(ECM 1.6.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR})

include(KDEInstallDirs)
set(CMAKE_AUTOMOC ON)

#this is used for mycroft spawning. It's horrible and should not be needed, but mycroft packaging is questionable at best
#in any sane world mycroft would install something in $PATH
set(MYCROFT_CORE_DIR "/opt/mycroft")

find_package(Qt5 ${QT_MIN_VERSION} CONFIG REQUIRED COMPONENTS
    Quick
    Core
    Qml
    Network
    WebSockets
)

SET(mycroft_gui_app_SRC
    main.cpp
)

qt5_add_resources(mycroft_gui_app_SRC
    qml.qrc
)

add_executable(mycroft-gui-app ${mycroft_gui_app_SRC})
target_link_libraries(mycroft-gui-app Qt5::Core Qt5::Quick)


install(TARGETS mycroft-gui-app ${INSTALL_TARGETS_DEFAULT_ARGS})
add_subdirectory(import)

install( PROGRAMS net.bs.mycroft.gui.desktop DESTINATION  ${KDE_INSTALL_APPDIR} )
install( PROGRAMS net.bs.mycroft.gui.device.desktop DESTINATION  ${KDE_INSTALL_APPDIR} )
install( PROGRAMS net.bs.mycroft.gui.device2.desktop DESTINATION  ${KDE_INSTALL_APPDIR} )
install( PROGRAMS net.bs.mycroft.gui.device3.desktop DESTINATION  ${KDE_INSTALL_APPDIR} )


install( DIRECTORY skills DESTINATION ${MYCROFT_CORE_DIR}/skills/ui
    PATTERN "*.qmlc" EXCLUDE
)

configure_file(data/mycroft-gui-core-loader.in ${CMAKE_CURRENT_BINARY_DIR}/mycroft-gui-core-loader)
install(PROGRAMS ${CMAKE_CURRENT_BINARY_DIR}/mycroft-gui-core-loader DESTINATION ${KDE_INSTALL_BINDIR})
