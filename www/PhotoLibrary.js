function noop() {}

function PhotoLibrary() {}

PhotoLibrary.fromImage = function (img, successCallback, failureCallback) {
  if (!img.complete) {
    return (failureCallback || noop)('Image has not been loaded')
  }

  var canvas = document.createElement('canvas')
  var ctx = canvas.getContext('2d')
  var devicePixelRatio = window.devicePixelRatio || 1
  var backingStoreRatio = ctx.webkitBackingStorePixelRatio || 1
  var ratio = devicePixelRatio / backingStoreRatio

  canvas.width = img.naturalWidth * ratio
  canvas.height = img.naturalHeight * ratio
  ctx.scale(ratio, ratio)

  ctx.drawImage(img, 0, 0, img.naturalWidth, img.naturalHeight)

  var base64Str = canvas.toDataURL().replace(/data:image\/png;base64,/,'')
  return PhotoLibrary.fromBase64(base64Str, successCallback, failureCallback)
}

PhotoLibrary.fromBase64 = function (base64Str, successCallback, failureCallback) {
  return cordova.exec(successCallback, failureCallback, 'PhotoLibrary', 'fromBase64', [base64Str]);
}

PhotoLibrary.fromUrl = function (imageUrl, successCallback, failureCallback) {
  return cordova.exec(successCallback, failureCallback, 'PhotoLibrary', 'fromUrl', [imageUrl]);
}

module.exports = PhotoLibrary
