function PhotoLibrary() {}

PhotoLibrary.imageFromImage = function (imgElm, successCallback, failureCallback) {
  if (!imgElm.complete) {
    failureCallback && failureCallback('Image has not been loaded')
    return
  }

  var canvas = document.createElement('canvas')
  var ctx = canvas.getContext('2d')
  var devicePixelRatio = window.devicePixelRatio || 1
  var backingStoreRatio = ctx.webkitBackingStorePixelRatio || 1
  var ratio = devicePixelRatio / backingStoreRatio

  canvas.width = imgElm.naturalWidth * ratio
  canvas.height = imgElm.naturalHeight * ratio
  ctx.scale(ratio, ratio)

  ctx.drawImage(imgElm, 0, 0, img.naturalWidth, img.naturalHeight)

  return PhotoLibrary.imageFromCanvas(canvas)
}

PhotoLibrary.imageFromCanvas = function (canvas, successCallback, failureCallback) {
  var base64Str = canvas.toDataURL().replace(/data:image\/png;base64,/,'')
  return PhotoLibrary.imageFromBase64(base64Str, successCallback, failureCallback)
}

PhotoLibrary.imageFromBase64 = function (base64Str, successCallback, failureCallback) {
  return PhotoLibrary.imageFromUrl('data:;base64,' + base64Str, successCallback, failureCallback)
}

PhotoLibrary.imageFromUrl = function (url, successCallback, failureCallback) {
  return cordova.exec(successCallback, failureCallback, 'PhotoLibrary', 'imageFromUrl', [url])
}

PhotoLibrary.videoFromUrl = function (url, successCallback, failureCallback) {
  return cordova.exec(successCallback, failureCallback, 'PhotoLibrary', 'videoFromUrl', [url])
}

module.exports = PhotoLibrary
