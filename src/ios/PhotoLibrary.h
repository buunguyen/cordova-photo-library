#import <Cordova/CDVPlugin.h>

@interface PhotoLibrary : CDVPlugin
{
  NSString* callbackId;
}

@property (nonatomic, copy) NSString* callbackId;

- (void)imageFromUrl:(CDVInvokedUrlCommand*)command;
- (void)videoFromUrl:(CDVInvokedUrlCommand*)command;

@end
