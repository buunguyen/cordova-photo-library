
#import "PhotoLibrary.h"
#import <Cordova/CDV.h>
#import <AssetsLibrary/AssetsLibrary.h>

@implementation PhotoLibrary

@synthesize callbackId;

- (void)imageFromUrl:(CDVInvokedUrlCommand *) command
{
    self.callbackId = command.callbackId;
    NSString* url = [command.arguments objectAtIndex:0];
    NSString* albumName = [command.arguments objectAtIndex:1];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];

    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library addAssetsGroupAlbumWithName:@"My Photo Album" resultBlock:^(ALAssetsGroup *group) {
        if(group == nil){
                //enumerate albums
                [library enumerateGroupsWithTypes:ALAssetsGroupAlbum
                                   usingBlock:^(ALAssetsGroup *g, BOOL *stop)
                 {
                     //if the album is equal to our album
                     if ([[g valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"My Photo Album"]) {

                         //save image
                        [library writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
                            NSString *assetUrlString = assetURL.absoluteString;
                            CDVPluginResult *result = error == NULL
                                ? [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsString:assetUrlString]
                                : [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString:error.description];

                            [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
                        }];
                     }
                 }failureBlock:^(NSError *error){

                 }];
        }else {
            [library writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
                NSString *assetUrlString = assetURL.absoluteString;
                CDVPluginResult *result = error == NULL
                    ? [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsString:assetUrlString]
                    : [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString:error.description];

                [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
            }];
        }
    }

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
            NSString *assetUrlString = assetURL.absoluteString;
            CDVPluginResult *result = error == NULL
                ? [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsString:assetUrlString]
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
