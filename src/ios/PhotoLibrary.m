#import "PhotoLibrary.h"
#import <Cordova/CDV.h>

@interface PhotoLibrary()
- (void)save:(UIImage *)image;
@end

@implementation PhotoLibrary
@synthesize callbackId;

- (void)fromBase64:(CDVInvokedUrlCommand*)command
{
  self.callbackId = command.callbackId;

  NSString *base64Str = [NSString stringWithFormat:@"data:;base64,%@", [command.arguments objectAtIndex:0]];
  NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:base64Str]];

  UIImage *image = [UIImage imageWithData:data];
  [self save:image];
}

- (void)fromUrl:(CDVInvokedUrlCommand*)command
{
  self.callbackId = command.callbackId;

  NSString* imageUrl = [command.arguments objectAtIndex:0];

  UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];
  [self save:image];
}

- (void)save:(UIImage *)image
{
  UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
  CDVPluginResult* result = error == NULL
    ? [CDVPluginResult resultWithStatus: CDVCommandStatus_OK]
    : [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString:error.description];
  [self.commandDelegate sendPluginResult:result callbackId:callbackId];
}

- (void)dealloc
{
  [callbackId release];
  [super dealloc];
}

@end
