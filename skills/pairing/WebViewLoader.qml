import QtQuick 2.4
import QtWebKit 3.0
import QtWebKit.experimental 1.0

WebView {
id: webview
url: "https://home.mycroft.ai"
anchors.fill: parent
onNavigationRequested: {
    var schemaRE = /^\w+:/;
    if (schemaRE.test(request.url)) {
        request.action = WebView.AcceptRequest;
    } else {
        request.action = WebView.IgnoreRequest;
    }
  }
}
