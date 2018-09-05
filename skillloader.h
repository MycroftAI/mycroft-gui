#pragma once

#include <QObject>
#include <QUrl>

class SkillLoader: public QObject
{
public:
    SkillLoader(QObject *parent=nullptr);
    ~SkillLoader();
    /**
      Searches all relevant folders for a UI that matches
      Files must be in the format $XDG_DATA_DIR/mycroft-gui/skills/$metaDataName/main.qml
    */
    Q_INVOKABLE QUrl uiForMetadataType(const QString &metaDataType) const;
};
