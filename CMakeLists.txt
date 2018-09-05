# Set minimum CMake version (required for CMake 3.0 or later)
cmake_minimum_required(VERSION 2.8.12)
 
set(QT_MIN_VERSION "5.9.0")
set(KF5_MIN_VERSION "5.0.0")
 
# Use Extra CMake Modules (ECM) for common functionality.
# See http://api.kde.org/ecm/manual/ecm.7.html
# and http://api.kde.org/ecm/manual/ecm-kde-modules.7.html 
find_package(ECM REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR} ${CMAKE_MODULE_PATH})
set(VERSION 2.1.0)

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings )
include(ECMInstallIcons)


find_package(Qt5 ${QT_MIN_VERSION} CONFIG REQUIRED COMPONENTS
    Quick
    Core
    Qml
    Network
    WebSockets
)

add_executable(mycroft-gui-app main.cpp)
target_link_libraries(mycroft-gui-app Qt5::Core Qt5::Quick Qt5::WebSockets)


install(TARGETS mycroft-gui-app ${INSTALL_TARGETS_DEFAULT_ARGS})
add_subdirectory(import)

install( DIRECTORY skills DESTINATION ${KDE_INSTALL_FULL_DATADIR}/mycroft-gui/
    PATTERN "*.qmlc" EXCLUDE
)
