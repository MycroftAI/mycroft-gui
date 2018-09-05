#pragma once

#include <QObject>
#include <QUrl>

class SkillLoader: public QObject
{
    Q_OBJECT
public:
    SkillLoader(QObject *parent=nullptr);
    ~SkillLoader();
    /**
      Searches all relevant folders for a UI that matches
      Files must be in the format $XDG_DATA_DIR/mycroft-gui/skills/$metaDataName/main.qml
    */
    Q_INVOKABLE QString uiForMetadataType(const QString &metaDataType) const;
};
