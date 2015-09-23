#import <Cordova/CDVPlugin.h>

@interface PhotoLibrary : CDVPlugin
{
  NSString* callbackId;
}

@property (nonatomic, copy) NSString* callbackId;

- (void)fromUrl:(CDVInvokedUrlCommand*)command;

@end
