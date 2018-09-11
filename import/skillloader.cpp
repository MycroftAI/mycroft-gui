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

QString SkillLoader::uiForMetadataType(const QString &metaDataType) const
{
    const QString filePath = "/opt/mycroft/skills/ui/skills/"+ metaDataType + "/Main.qml";
    qDebug() << "query" << filePath;
    if (QFileInfo::exists(filePath)) {
        return  QUrl::fromLocalFile(filePath).toString();
    }
    qWarning() << "could not find delegate for " << metaDataType;
    return QString();
}
