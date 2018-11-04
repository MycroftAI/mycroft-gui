project(mycroftimport)



set(mycroftimport_SRCS
    mycroftplugin.cpp
    mycroftcontroller.cpp
    delegate.cpp
    skillloader.cpp
    intentwatcher.cpp
    globalsettings.cpp
    filereader.cpp
    )

    
include_directories(${CMAKE_CURRENT_BINARY_DIR})

add_library(mycroftplugin SHARED ${mycroftimport_SRCS} ${RESOURCES})

if (CMAKE_SYSTEM_NAME STREQUAL "Android")
    set(mycroftplugin_EXTRA_LIBS
        Qt5::TextToSpeech
    )
endif()

target_link_libraries(mycroftplugin
        PUBLIC
            Qt5::Core
            ${mycroftplugin_EXTRA_LIBS}
        PRIVATE
            Qt5::Qml
            Qt5::Quick
            Qt5::Network
            Qt5::WebSockets
    )


install(TARGETS mycroftplugin DESTINATION ${KDE_INSTALL_QMLDIR}/Mycroft)

install(FILES qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/Mycroft)
install(DIRECTORY qml/ DESTINATION ${KDE_INSTALL_QMLDIR}/Mycroft)

