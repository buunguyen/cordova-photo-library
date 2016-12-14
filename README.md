PhotoLibrary
============

This plugin is an updated fork of https://github.com/buunguyen/cordova-photo-library using the newer Photos framework.
This plugin allows you to save images and videos to photo library or in a custom album within the photo library. Currently this plugin only supports iOS. (pull requests are very welcome).

Note: Photo Library only available in iOS 8+

```
cordova plugin add https://github.com/CoSchedule/cordova-photo-library.git
```


Methods
------

 - Image from Image
   ```
   const options = {
       imgElm: //required,
       albumName: //optional,
   }
       
   cordova.plugins.PhotoLibrary.imageFromImage(options, callback, errback) // imgElm  must have been loaded
   
   ```
- Image from Canvas
  ```
    const options = {
         canvas: //required,
         albumName: //optional,
     }
      
    cordova.plugins.PhotoLibrary.imageFromCanvas(options, callback, errback)
  
  ```
- Image from Base64
  ```
    const options = {
        base64String: //required,
        albumName: //optional,
    }
      
    cordova.plugins.PhotoLibrary.imageFromBase64(options, callback, errback)
  
  ```
  
- Image from URL
  ```
    const options = {
        url: //required,
        albumName: //optional,
    }
      
    cordova.plugins.PhotoLibrary.imageFromUrl(options, callback, errback)
  
  ```  
- Video from URL
  ```
    const options = {
        url: //required,
        albumName: //optional,
    }
      
    cordova.plugins.PhotoLibrary.videofromUrl(options, callback, errback)
  
  ```
