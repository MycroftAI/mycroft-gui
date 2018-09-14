#include "skillloader.h"

#include <QStandardPaths>
#include <QFileInfo>
#include <QDebug>

#include <config-mycroft.h>

SkillLoader::SkillLoader(QObject *parent):
    QObject(parent)
{

}

SkillLoader::~SkillLoader()
{
}

QString SkillLoader::uiForMetadataType(const QString &metaDataType) const
{
    if (metaDataType.isEmpty()) {
        return QString();
    }
    const QString filePath = MYCROFT_SKILLS_UI_DIR + QLatin1String("/") + metaDataType + "/Main.qml";
    qDebug() << "looking for" << filePath;
    if (QFileInfo::exists(filePath)) {
        return  QUrl::fromLocalFile(filePath).toString();
    }
    qWarning() << "could not find delegate for " << metaDataType;
    return QString();
}
