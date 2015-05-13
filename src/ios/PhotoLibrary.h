#import <Cordova/CDVPlugin.h>

@interface PhotoLibrary : CDVPlugin
{
  NSString* callbackId;
}

@property (nonatomic, copy) NSString* callbackId;

- (void)fromBase64:(CDVInvokedUrlCommand*)command;
- (void)fromUrl:(CDVInvokedUrlCommand*)command;

@end
