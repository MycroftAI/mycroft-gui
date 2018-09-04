/****************************************************************************
** Meta object code from reading C++ file 'wsocket.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.11.1)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "wsocket.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'wsocket.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.11.1. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
struct qt_meta_stringdata_WSocket_t {
    QByteArrayData data[21];
    char stringdata0[219];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_WSocket_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_WSocket_t qt_meta_stringdata_WSocket = {
    {
QT_MOC_LITERAL(0, 0, 7), // "WSocket"
QT_MOC_LITERAL(1, 8, 15), // "messageReceived"
QT_MOC_LITERAL(2, 24, 0), // ""
QT_MOC_LITERAL(3, 25, 7), // "message"
QT_MOC_LITERAL(4, 33, 19), // "socketStatusChanged"
QT_MOC_LITERAL(5, 53, 6), // "closed"
QT_MOC_LITERAL(6, 60, 11), // "onConnected"
QT_MOC_LITERAL(7, 72, 4), // "open"
QT_MOC_LITERAL(8, 77, 3), // "url"
QT_MOC_LITERAL(9, 81, 21), // "onTextMessageReceived"
QT_MOC_LITERAL(10, 103, 13), // "onSendMessage"
QT_MOC_LITERAL(11, 117, 15), // "onStatusChanged"
QT_MOC_LITERAL(12, 133, 28), // "QAbstractSocket::SocketState"
QT_MOC_LITERAL(13, 162, 5), // "state"
QT_MOC_LITERAL(14, 168, 6), // "status"
QT_MOC_LITERAL(15, 175, 6), // "Status"
QT_MOC_LITERAL(16, 182, 10), // "Connecting"
QT_MOC_LITERAL(17, 193, 4), // "Open"
QT_MOC_LITERAL(18, 198, 7), // "Closing"
QT_MOC_LITERAL(19, 206, 6), // "Closed"
QT_MOC_LITERAL(20, 213, 5) // "Error"

    },
    "WSocket\0messageReceived\0\0message\0"
    "socketStatusChanged\0closed\0onConnected\0"
    "open\0url\0onTextMessageReceived\0"
    "onSendMessage\0onStatusChanged\0"
    "QAbstractSocket::SocketState\0state\0"
    "status\0Status\0Connecting\0Open\0Closing\0"
    "Closed\0Error"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_WSocket[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
       9,   14, // methods
       1,   78, // properties
       1,   82, // enums/sets
       0,    0, // constructors
       0,       // flags
       3,       // signalCount

 // signals: name, argc, parameters, tag, flags
       1,    1,   59,    2, 0x06 /* Public */,
       4,    0,   62,    2, 0x06 /* Public */,
       5,    0,   63,    2, 0x06 /* Public */,

 // slots: name, argc, parameters, tag, flags
       6,    0,   64,    2, 0x0a /* Public */,
       7,    1,   65,    2, 0x0a /* Public */,
       9,    1,   68,    2, 0x0a /* Public */,
      10,    1,   71,    2, 0x0a /* Public */,
      11,    1,   74,    2, 0x0a /* Public */,
      14,    0,   77,    2, 0x0a /* Public */,

 // signals: parameters
    QMetaType::Void, QMetaType::QString,    3,
    QMetaType::Void,
    QMetaType::Void,

 // slots: parameters
    QMetaType::Void,
    QMetaType::Void, QMetaType::QUrl,    8,
    QMetaType::Void, QMetaType::QString,    3,
    QMetaType::Void, QMetaType::QString,    3,
    QMetaType::Void, 0x80000000 | 12,   13,
    0x80000000 | 15,

 // properties: name, type, flags
      14, 0x80000000 | 15, 0x00495009,

 // properties: notify_signal_id
       1,

 // enums: name, flags, count, data
      15, 0x0,    5,   86,

 // enum data: key, value
      16, uint(WSocket::Connecting),
      17, uint(WSocket::Open),
      18, uint(WSocket::Closing),
      19, uint(WSocket::Closed),
      20, uint(WSocket::Error),

       0        // eod
};

void WSocket::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        WSocket *_t = static_cast<WSocket *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->messageReceived((*reinterpret_cast< QString(*)>(_a[1]))); break;
        case 1: _t->socketStatusChanged(); break;
        case 2: _t->closed(); break;
        case 3: _t->onConnected(); break;
        case 4: _t->open((*reinterpret_cast< const QUrl(*)>(_a[1]))); break;
        case 5: _t->onTextMessageReceived((*reinterpret_cast< QString(*)>(_a[1]))); break;
        case 6: _t->onSendMessage((*reinterpret_cast< QString(*)>(_a[1]))); break;
        case 7: _t->onStatusChanged((*reinterpret_cast< QAbstractSocket::SocketState(*)>(_a[1]))); break;
        case 8: { Status _r = _t->status();
            if (_a[0]) *reinterpret_cast< Status*>(_a[0]) = std::move(_r); }  break;
        default: ;
        }
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        switch (_id) {
        default: *reinterpret_cast<int*>(_a[0]) = -1; break;
        case 7:
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
            using _t = void (WSocket::*)(QString );
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&WSocket::messageReceived)) {
                *result = 0;
                return;
            }
        }
        {
            using _t = void (WSocket::*)();
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&WSocket::socketStatusChanged)) {
                *result = 1;
                return;
            }
        }
        {
            using _t = void (WSocket::*)();
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&WSocket::closed)) {
                *result = 2;
                return;
            }
        }
    }
#ifndef QT_NO_PROPERTIES
    else if (_c == QMetaObject::ReadProperty) {
        WSocket *_t = static_cast<WSocket *>(_o);
        Q_UNUSED(_t)
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast< Status*>(_v) = _t->status(); break;
        default: break;
        }
    } else if (_c == QMetaObject::WriteProperty) {
    } else if (_c == QMetaObject::ResetProperty) {
    }
#endif // QT_NO_PROPERTIES
}

QT_INIT_METAOBJECT const QMetaObject WSocket::staticMetaObject = {
    { &QObject::staticMetaObject, qt_meta_stringdata_WSocket.data,
      qt_meta_data_WSocket,  qt_static_metacall, nullptr, nullptr}
};


const QMetaObject *WSocket::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *WSocket::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_WSocket.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int WSocket::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 9)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 9;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 9)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 9;
    }
#ifndef QT_NO_PROPERTIES
   else if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 1;
    } else if (_c == QMetaObject::QueryPropertyDesignable) {
        _id -= 1;
    } else if (_c == QMetaObject::QueryPropertyScriptable) {
        _id -= 1;
    } else if (_c == QMetaObject::QueryPropertyStored) {
        _id -= 1;
    } else if (_c == QMetaObject::QueryPropertyEditable) {
        _id -= 1;
    } else if (_c == QMetaObject::QueryPropertyUser) {
        _id -= 1;
    }
#endif // QT_NO_PROPERTIES
    return _id;
}

// SIGNAL 0
void WSocket::messageReceived(QString _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 0, _a);
}

// SIGNAL 1
void WSocket::socketStatusChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 1, nullptr);
}

// SIGNAL 2
void WSocket::closed()
{
    QMetaObject::activate(this, &staticMetaObject, 2, nullptr);
}
QT_WARNING_POP
QT_END_MOC_NAMESPACE
