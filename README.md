PhotoLibrary
============

This plugin allows you to save images to photo library. Currently this plugin only supports iOS. Support for other platforms will come later (pull requests are very welcome).

```
cordova plugin add https://github.com/buunguyen/cordova-photo-library.git
```

Methods
------

* cordova.plugins.PhotoLibrary.fromImage(img, callback, errback) // img must have been loaded
* cordova.plugins.PhotoLibrary.fromCanvas(canvas, callback, errback)
* cordova.plugins.PhotoLibrary.fromBase64(base64String, callback, errback)
* cordova.plugins.PhotoLibrary.fromUrl(options, callback, errback)
where options = {imageUrl: url, albumName: albumName}
