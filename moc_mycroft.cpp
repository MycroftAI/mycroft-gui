/****************************************************************************
** Meta object code from reading C++ file 'mycroft.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.11.1)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "mycroft.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'mycroft.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.11.1. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
struct qt_meta_stringdata_Mycroft_t {
    QByteArrayData data[29];
    char stringdata0[304];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_Mycroft_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_Mycroft_t qt_meta_stringdata_Mycroft = {
    {
QT_MOC_LITERAL(0, 0, 7), // "Mycroft"
QT_MOC_LITERAL(1, 8, 19), // "socketStatusChanged"
QT_MOC_LITERAL(2, 28, 0), // ""
QT_MOC_LITERAL(3, 29, 6), // "closed"
QT_MOC_LITERAL(4, 36, 17), // "isSpeakingChanged"
QT_MOC_LITERAL(5, 54, 19), // "currentSkillChanged"
QT_MOC_LITERAL(6, 74, 17), // "skillDataRecieved"
QT_MOC_LITERAL(7, 92, 5), // "skill"
QT_MOC_LITERAL(8, 98, 4), // "data"
QT_MOC_LITERAL(9, 103, 4), // "open"
QT_MOC_LITERAL(10, 108, 3), // "url"
QT_MOC_LITERAL(11, 112, 11), // "sendRequest"
QT_MOC_LITERAL(12, 124, 4), // "json"
QT_MOC_LITERAL(13, 129, 8), // "sendText"
QT_MOC_LITERAL(14, 138, 7), // "message"
QT_MOC_LITERAL(15, 146, 11), // "onConnected"
QT_MOC_LITERAL(16, 158, 21), // "onTextMessageReceived"
QT_MOC_LITERAL(17, 180, 15), // "onStatusChanged"
QT_MOC_LITERAL(18, 196, 28), // "QAbstractSocket::SocketState"
QT_MOC_LITERAL(19, 225, 5), // "state"
QT_MOC_LITERAL(20, 231, 6), // "status"
QT_MOC_LITERAL(21, 238, 6), // "Status"
QT_MOC_LITERAL(22, 245, 8), // "speaking"
QT_MOC_LITERAL(23, 254, 12), // "currentSkill"
QT_MOC_LITERAL(24, 267, 10), // "Connecting"
QT_MOC_LITERAL(25, 278, 4), // "Open"
QT_MOC_LITERAL(26, 283, 7), // "Closing"
QT_MOC_LITERAL(27, 291, 6), // "Closed"
QT_MOC_LITERAL(28, 298, 5) // "Error"

    },
    "Mycroft\0socketStatusChanged\0\0closed\0"
    "isSpeakingChanged\0currentSkillChanged\0"
    "skillDataRecieved\0skill\0data\0open\0url\0"
    "sendRequest\0json\0sendText\0message\0"
    "onConnected\0onTextMessageReceived\0"
    "onStatusChanged\0QAbstractSocket::SocketState\0"
    "state\0status\0Status\0speaking\0currentSkill\0"
    "Connecting\0Open\0Closing\0Closed\0Error"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_Mycroft[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
      11,   14, // methods
       3,   94, // properties
       1,  106, // enums/sets
       0,    0, // constructors
       0,       // flags
       5,       // signalCount

 // signals: name, argc, parameters, tag, flags
       1,    0,   69,    2, 0x06 /* Public */,
       3,    0,   70,    2, 0x06 /* Public */,
       4,    0,   71,    2, 0x06 /* Public */,
       5,    0,   72,    2, 0x06 /* Public */,
       6,    2,   73,    2, 0x06 /* Public */,

 // slots: name, argc, parameters, tag, flags
       9,    1,   78,    2, 0x0a /* Public */,
      11,    1,   81,    2, 0x0a /* Public */,
      13,    1,   84,    2, 0x0a /* Public */,
      15,    0,   87,    2, 0x08 /* Private */,
      16,    1,   88,    2, 0x08 /* Private */,
      17,    1,   91,    2, 0x08 /* Private */,

 // signals: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, QMetaType::QString, QMetaType::QVariantMap,    7,    8,

 // slots: parameters
    QMetaType::Void, QMetaType::QUrl,   10,
    QMetaType::Void, QMetaType::QString,   12,
    QMetaType::Void, QMetaType::QString,   14,
    QMetaType::Void,
    QMetaType::Void, QMetaType::QString,   14,
    QMetaType::Void, 0x80000000 | 18,   19,

 // properties: name, type, flags
      20, 0x80000000 | 21, 0x00495009,
      22, QMetaType::Bool, 0x00495001,
      23, QMetaType::QString, 0x00495001,

 // properties: notify_signal_id
       0,
       2,
       3,

 // enums: name, flags, count, data
      21, 0x0,    5,  110,

 // enum data: key, value
      24, uint(Mycroft::Connecting),
      25, uint(Mycroft::Open),
      26, uint(Mycroft::Closing),
      27, uint(Mycroft::Closed),
      28, uint(Mycroft::Error),

       0        // eod
};

void Mycroft::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        Mycroft *_t = static_cast<Mycroft *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->socketStatusChanged(); break;
        case 1: _t->closed(); break;
        case 2: _t->isSpeakingChanged(); break;
        case 3: _t->currentSkillChanged(); break;
        case 4: _t->skillDataRecieved((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QVariantMap(*)>(_a[2]))); break;
        case 5: _t->open((*reinterpret_cast< const QUrl(*)>(_a[1]))); break;
        case 6: _t->sendRequest((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 7: _t->sendText((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 8: _t->onConnected(); break;
        case 9: _t->onTextMessageReceived((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 10: _t->onStatusChanged((*reinterpret_cast< QAbstractSocket::SocketState(*)>(_a[1]))); break;
        default: ;
        }
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        switch (_id) {
        default: *reinterpret_cast<int*>(_a[0]) = -1; break;
        case 10:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< QAbstractSocket::SocketState >(); break;
            }
            break;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        {
            using _t = void (Mycroft::*)();
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&Mycroft::socketStatusChanged)) {
                *result = 0;
                return;
            }
        }
        {
            using _t = void (Mycroft::*)();
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&Mycroft::closed)) {
                *result = 1;
                return;
            }
        }
        {
            using _t = void (Mycroft::*)();
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&Mycroft::isSpeakingChanged)) {
                *result = 2;
                return;
            }
        }
        {
            using _t = void (Mycroft::*)();
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&Mycroft::currentSkillChanged)) {
                *result = 3;
                return;
            }
        }
        {
            using _t = void (Mycroft::*)(const QString & , const QVariantMap & );
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&Mycroft::skillDataRecieved)) {
                *result = 4;
                return;
            }
        }
    }
#ifndef QT_NO_PROPERTIES
    else if (_c == QMetaObject::ReadProperty) {
        Mycroft *_t = static_cast<Mycroft *>(_o);
        Q_UNUSED(_t)
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast< Status*>(_v) = _t->status(); break;
        case 1: *reinterpret_cast< bool*>(_v) = _t->isSpeaking(); break;
        case 2: *reinterpret_cast< QString*>(_v) = _t->currentSkill(); break;
        default: break;
        }
    } else if (_c == QMetaObject::WriteProperty) {
    } else if (_c == QMetaObject::ResetProperty) {
    }
#endif // QT_NO_PROPERTIES
}

QT_INIT_METAOBJECT const QMetaObject Mycroft::staticMetaObject = {
    { &QObject::staticMetaObject, qt_meta_stringdata_Mycroft.data,
      qt_meta_data_Mycroft,  qt_static_metacall, nullptr, nullptr}
};


const QMetaObject *Mycroft::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *Mycroft::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_Mycroft.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int Mycroft::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 11)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 11;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 11)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 11;
    }
#ifndef QT_NO_PROPERTIES
   else if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 3;
    } else if (_c == QMetaObject::QueryPropertyDesignable) {
        _id -= 3;
    } else if (_c == QMetaObject::QueryPropertyScriptable) {
        _id -= 3;
    } else if (_c == QMetaObject::QueryPropertyStored) {
        _id -= 3;
    } else if (_c == QMetaObject::QueryPropertyEditable) {
        _id -= 3;
    } else if (_c == QMetaObject::QueryPropertyUser) {
        _id -= 3;
    }
#endif // QT_NO_PROPERTIES
    return _id;
}

// SIGNAL 0
void Mycroft::socketStatusChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}

// SIGNAL 1
void Mycroft::closed()
{
    QMetaObject::activate(this, &staticMetaObject, 1, nullptr);
}

// SIGNAL 2
void Mycroft::isSpeakingChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 2, nullptr);
}

// SIGNAL 3
void Mycroft::currentSkillChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 3, nullptr);
}

// SIGNAL 4
void Mycroft::skillDataRecieved(const QString & _t1, const QVariantMap & _t2)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(&_t1)), const_cast<void*>(reinterpret_cast<const void*>(&_t2)) };
    QMetaObject::activate(this, &staticMetaObject, 4, _a);
}
QT_WARNING_POP
QT_END_MOC_NAMESPACE
