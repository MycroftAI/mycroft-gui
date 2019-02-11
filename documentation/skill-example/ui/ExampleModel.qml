import QtQuick.Layouts 1.4
import QtQuick 2.4
import QtQuick.Controls 2.0
import org.kde.kirigami 2.5 as Kirigami
import Mycroft 1.0 as Mycroft

ListModel {
    id: settingsListModel
    
    ListElement {
        exampleIcon: "beamerblock"
        exampleLabel: "Simple Text Example"
        exampleEvent: "skillExample.simpleText"
    }
    ListElement {
        exampleIcon: "beamerblock"
        exampleLabel: "Simple Image Example"
        exampleEvent: "skillExample.simpleImage"
    }
    ListElement {
        exampleIcon: "beamerblock"
        exampleLabel: "Paginated Text Example"
        exampleEvent: "skillExample.paginatedText"
    }
    ListElement {
        exampleIcon: "beamerblock"
        exampleLabel: "Sliding Image Example"
        exampleEvent: "skillExample.slidingImage"
    }
    ListElement {
        exampleIcon: "beamerblock"
        exampleLabel: "Proportion Delegate & Autofit Label"
        exampleEvent: "skillExample.proportionalDelegate"
    }
    ListElement {
        exampleIcon: "beamerblock"
        exampleLabel: "Cards ListView"
        exampleEvent: "skillExample.listView" 
    }
    ListElement {
        exampleIcon: "beamerblock"
        exampleLabel: "Events Example"
        exampleEvent: "skillExample.eventsExample" 
    }
}
