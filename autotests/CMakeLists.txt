include(ECMAddTests)

find_package(Qt5 ${REQUIRED_QT_VERSION} NO_MODULE REQUIRED Test)
set_package_properties(Qt5Test PROPERTIES PURPOSE "Required for autotests")

include_directories(${CMAKE_CURRENT_BINARY_DIR} ${CMAKE_CURRENT_BINARY_DIR}/../import)

set(import_SRCS
    ${CMAKE_SOURCE_DIR}/import/abstractdelegate.cpp
    ${CMAKE_SOURCE_DIR}/import/mycroftcontroller.cpp
    ${CMAKE_SOURCE_DIR}/import/activeskillsmodel.cpp
    ${CMAKE_SOURCE_DIR}/import/delegatesmodel.cpp
    ${CMAKE_SOURCE_DIR}/import/sessiondatamap.cpp
    ${CMAKE_SOURCE_DIR}/import/sessiondatamodel.cpp
    ${CMAKE_SOURCE_DIR}/import/filereader.cpp
    ${CMAKE_SOURCE_DIR}/import/globalsettings.cpp
    ${CMAKE_SOURCE_DIR}/import/abstractskillview.cpp
   )

qt5_add_resources(import_SRCS ${CMAKE_SOURCE_DIR}/import/mycroft.qrc)

ecm_add_test(
  servertest.cpp
  ${import_SRCS}
  ${RESOURCES}

  TEST_NAME servertest

  LINK_LIBRARIES
    Qt5::Test
    Qt5::Qml
    Qt5::Quick
    Qt5::Network
    Qt5::WebSockets
    Qt5::Multimedia
)

ecm_add_test(
  modeltest.cpp
  ${import_SRCS}
  ${RESOURCES}

  TEST_NAME modeltest

  LINK_LIBRARIES
    Qt5::Test
    Qt5::Qml
    Qt5::Quick
    Qt5::Network
    Qt5::WebSockets
    Qt5::Multimedia
)

ecm_add_test(
  stresstest.cpp
  ${import_SRCS}
  ${RESOURCES}

  TEST_NAME stresstest

  LINK_LIBRARIES
    Qt5::Test
    Qt5::Qml
    Qt5::Quick
    Qt5::Network
    Qt5::WebSockets
    Qt5::Multimedia
)
