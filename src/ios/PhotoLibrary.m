#import "PhotoLibrary.h"
#import <Cordova/CDV.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface PhotoLibrary()
- (void) save:(NSString *) imageUrl;
@end

@implementation PhotoLibrary

@synthesize callbackId;

- (void)fromUrl:(CDVInvokedUrlCommand *) command
{
    self.callbackId = command.callbackId;
    NSString* imageUrl = [command.arguments objectAtIndex:0];
    [self save:imageUrl];
}

- (void)save:(NSString *) imageUrl
{
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
        CDVPluginResult *result = error == NULL
            ? [CDVPluginResult resultWithStatus: CDVCommandStatus_OK]
            : [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString:error.description];

        [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
    }];
}

- (void)dealloc
{
    [callbackId release];
    [super dealloc];
}

@end
