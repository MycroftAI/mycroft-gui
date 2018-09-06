project(mycroftimport)



set(mycroftimport_SRCS
    mycroftplugin.cpp
    mycroftcontroller.cpp
    skillloader.cpp
    )


add_library(mycroftplugin SHARED ${mycroftimport_SRCS} ${RESOURCES})


target_link_libraries(mycroftplugin
        PUBLIC
            Qt5::Core
        PRIVATE
            Qt5::Qml
            Qt5::Quick
            Qt5::Network
            Qt5::WebSockets
    )


install(TARGETS mycroftplugin DESTINATION ${KDE_INSTALL_QMLDIR}/Mycroft)

install(FILES qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/Mycroft)
install(DIRECTORY qml/ DESTINATION ${KDE_INSTALL_QMLDIR}/Mycroft)

