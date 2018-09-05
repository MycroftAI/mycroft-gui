#include "skillloader.h"

#include <QStandardPaths>
#include <QFileInfo>
#include <QDebug>

SkillLoader::SkillLoader(QObject *parent):
    QObject(parent)
{

}

SkillLoader::~SkillLoader()
{
}

QUrl SkillLoader::uiForMetadataType(const QString &metaDataType) const
{
    const QStringList &dirs = QStandardPaths::locateAll(QStandardPaths::DataLocation, "mycroft-gui", QStandardPaths::LocateDirectory);
    for(const QString &dir: dirs) {
        const QString filePath = dir + "/skills/"+ metaDataType + "/main.qml";
        if (QFileInfo::exists(filePath)) {
            return  filePath;
        }
    }
    qWarning() << "could not find delegate for " << metaDataType;
    return QUrl();
}
