
var desktopsArray = desktopsForActivity(currentActivity());
for (var j = 0; j < desktopsArray.length; j++) {
    var desk = desktopsArray[j];
    desk.wallpaperPlugin = "org.kde.color";

    desk.currentConfigGroup = new Array("Wallpaper", "org.kde.color", "General");
    desk.writeConfig("Color", "0,0,0");
}

