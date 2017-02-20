function PhotoLibrary() {
}

PhotoLibrary.imageFromImage = function (options, successCallback, failureCallback) {
  var imgElm = options.imgElm;
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

  var options = {
    canvas: canvas,
  }

  return PhotoLibrary.imageFromCanvas(options)
}

PhotoLibrary.imageFromCanvas = function (options, successCallback, failureCallback) {

  options['url'] = options.canvas.toDataURL().replace(/data:image\/png;base64,/, '');

  return PhotoLibrary.imageFromBase64(options, successCallback, failureCallback)
}

PhotoLibrary.imageFromBase64 = function (options, successCallback, failureCallback) {

  options['url'] = 'data:;base64,' + options.base64Str;

  return PhotoLibrary.imageFromUrl(options, successCallback, failureCallback)
}

PhotoLibrary.imageFromUrl = function (options, successCallback, failureCallback) {

  var defaults = {
    url: encodeURI(options.url), //required
    albumName: null,
  }

  for (var key in defaults) {
    if (typeof options[key] !== "undefined")
      defaults[key] = options[key];
  }

  return cordova.exec(successCallback, failureCallback, 'PhotoLibrary', 'imageFromUrl', [defaults])
}

//noinspection Eslint
PhotoLibrary.videoFromUrl = function (options, successCallback, failureCallback) {

  var defaults = {
    url: encodeURI(options.url), //required
    albumName: null,
  }

  for (var key in defaults) {
    if (typeof options[key] !== "undefined")
      defaults[key] = options[key];
  }

  return cordova.exec(successCallback, failureCallback, 'PhotoLibrary', 'videoFromUrl', [defaults])
}

module.exports = PhotoLibrary
