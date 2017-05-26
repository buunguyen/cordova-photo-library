#import <Cordova/CDVPlugin.h>

@interface PhotoLibrary : CDVPlugin
{
  NSString* callbackId;
  NSString* localId;
}

@property (nonatomic, copy) NSString* callbackId;
@property (nonatomic, copy) NSString* localId;

- (void)imageFromUrl:(CDVInvokedUrlCommand*)command;
- (void)videoFromUrl:(CDVInvokedUrlCommand*)command;

@end
