#import "PhotoLibrary.h"
#import <Cordova/CDV.h>
#import <AssetsLibrary/AssetsLibrary.h>

@implementation PhotoLibrary

@synthesize callbackId;

- (void)imageFromUrl:(CDVInvokedUrlCommand *) command
{
    self.callbackId = command.callbackId;
    NSString* url = [command.arguments objectAtIndex:0];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];

    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
        CDVPluginResult *result = error == NULL
            ? [CDVPluginResult resultWithStatus: CDVCommandStatus_OK]
            : [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString:error.description];

        [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
    }];
}

- (void)videoFromUrl:(CDVInvokedUrlCommand *) command
{
    self.callbackId = command.callbackId;
    NSString* url = [command.arguments objectAtIndex:0];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];

    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"file.mov"];
    [data writeToFile:path atomically:YES];
    NSURL *pathUrl = [NSURL fileURLWithPath:path];

    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:pathUrl]) {
        [library writeVideoAtPathToSavedPhotosAlbum:pathUrl completionBlock:^(NSURL *assetURL, NSError *error) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];

            CDVPluginResult *result = error == NULL
                ? [CDVPluginResult resultWithStatus: CDVCommandStatus_OK]
                : [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString:error.description];

            [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
        }];
    }
    else {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString:@"Incompatible format"];
        [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
    }
}

- (void)dealloc
{
    [callbackId release];
    [super dealloc];
}

@end
