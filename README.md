PhotoLibrary
============

This plugin allows you to save images and videos to photo library. Currently this plugin only supports iOS. Support for other platforms will come later (pull requests are very welcome).

```
cordova plugin add https://github.com/buunguyen/cordova-photo-library.git
```

Methods
------

* cordova.plugins.PhotoLibrary.imageFromImage(imgElm, callback, errback) // imgElm  must have been loaded
* cordova.plugins.PhotoLibrary.imageFromCanvas(canvas, callback, errback)
* cordova.plugins.PhotoLibrary.imageFromBase64(base64String, callback, errback)
* cordova.plugins.PhotoLibrary.imageFromUrl(url, callback, errback)
* cordova.plugins.PhotoLibrary.videofromUrl(url, callback, errback)
