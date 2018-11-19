include(ECMAddTests)

find_package(Qt5 ${REQUIRED_QT_VERSION} NO_MODULE REQUIRED Test)
set_package_properties(Qt5Test PROPERTIES PURPOSE "Required for autotests")

ecm_add_test(
  servertest.cpp
  ${CMAKE_SOURCE_DIR}/import/abstractdelegate.cpp
  ${CMAKE_SOURCE_DIR}/import/mycroftcontroller.cpp
  ${CMAKE_SOURCE_DIR}/import/activeskillsmodel.cpp
  ${CMAKE_SOURCE_DIR}/import/delegatesmodel.cpp
  ${CMAKE_SOURCE_DIR}/import/sessiondatamap.cpp
  ${CMAKE_SOURCE_DIR}/import/sessiondatamodel.cpp
  ${CMAKE_SOURCE_DIR}/import/globalsettings.cpp
  ${CMAKE_SOURCE_DIR}/import/abstractskillview.cpp

  TEST_NAME servertest

  LINK_LIBRARIES
    Qt5::Test
    Qt5::Qml
    Qt5::Quick
    Qt5::Network
    Qt5::WebSockets
)
