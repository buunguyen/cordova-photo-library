PhotoLibrary
============

This plugin allows you to save images to photo library. Currently this plugin only supports iOS. Support for other devices will come later.

```
cordova plugin add https://github.com/buunguyen/cordova-photo-library.git
```

Methods
------

* cordova.plugins.PhotoLibrary.fromImage(img, callback, errback) // img must have been loaded
* cordova.plugins.PhotoLibrary.fromBase64(base64String, callback, errback)
* cordova.plugins.PhotoLibrary.fromUrl(url, callback, errback)
