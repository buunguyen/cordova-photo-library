
#import "PhotoLibrary.h"
#import <Cordova/CDV.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@implementation PhotoLibrary

@synthesize callbackId;
@synthesize localId;


- (void)insertImage:(UIImage *)image intoAlbumNamed:(NSString *)albumName {
    //Fetch a collection in the photos library that has the title "albumName"
    PHAssetCollection *collection = [self fetchAssetCollectionWithAlbumName: albumName];

    if (collection == nil) {
        //If we were unable to find a collection named "albumName" we'll create it before inserting the image
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle: albumName];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"Error inserting image into album: %@", error.localizedDescription);
                [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString:error.description];
            }

            if (success) {
                //Fetch the newly created collection (which we *assume* exists here)
                PHAssetCollection *newCollection = [self fetchAssetCollectionWithAlbumName:albumName];
               [self insertImage:image intoAssetCollection: newCollection];
            }
        }];
    } else {
        //If we found the existing AssetCollection with the title "albumName", insert into it
         [self insertImage:image intoAssetCollection: collection];
    }
}

- (PHAssetCollection *)fetchAssetCollectionWithAlbumName:(NSString *)albumName {
    PHFetchOptions *fetchOptions = [PHFetchOptions new];
    //Provide the predicate to match the title of the album.
    fetchOptions.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"title == '%@'", albumName]];

    //Fetch the album using the fetch option
    PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:fetchOptions];

    //Assuming the album exists and no album shares it's name, it should be the only result fetched
    return fetchResult.firstObject;
}

- (void)insertImage:(UIImage *)image intoAssetCollection:(PHAssetCollection *)collection {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{

        //This will request a PHAsset be created for the UIImage
        PHAssetCreationRequest *creationRequest = [PHAssetCreationRequest creationRequestForAssetFromImage:image];

        //Create a change request to insert the new PHAsset in the collection
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];

        self.localId = [[creationRequest placeholderForCreatedAsset] localIdentifier];

        NSLog(@"Local ID: %@", self.localId);
        //Add the PHAsset placeholder into the creation request.
        //The placeholder is used because the actual PHAsset hasn't been created yet
        if (request != nil && creationRequest.placeholderForCreatedAsset != nil) {
            [request addAssets: @[creationRequest.placeholderForCreatedAsset]];
        }
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error inserting image into asset collection: %@", error.localizedDescription);
            [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString:error.description];
        }
        if (success){
            [self returnToCordova:self.localId];
        }
    }];
}

- (void)returnToCordova:(NSString *)assetId {
    CDVPluginResult *result = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsString:assetId];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
}



- (void)imageFromUrl:(CDVInvokedUrlCommand *) command
{
    self.callbackId = command.callbackId;
    NSString* url = [command.arguments objectAtIndex:0];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    UIImage *image = [UIImage imageWithData:data];

    [self insertImage:image intoAlbumNamed: @"My Album"];



//    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//    [library addAssetsGroupAlbumWithName:@"My Photo Album" resultBlock:^(ALAssetsGroup *group) {
//        if(group == nil){
//                //enumerate albums
//                [library enumerateGroupsWithTypes:ALAssetsGroupAlbum
//                                   usingBlock:^(ALAssetsGroup *g, BOOL *stop)
//                 {
//                     //if the album is equal to our album
//                     if ([[g valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"My Photo Album"]) {
//
//                         //save image
//                        [library writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
//                            NSString *assetUrlString = assetURL.absoluteString;
//                            CDVPluginResult *result = error == NULL
//                                ? [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsString:assetUrlString]
//                                : [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString:error.description];
//
//                            [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
//                        }];
//                     }
//                 }failureBlock:^(NSError *error){
//
//                 }];
//        }else {
//            [library writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
//                NSString *assetUrlString = assetURL.absoluteString;
//                CDVPluginResult *result = error == NULL
//                    ? [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsString:assetUrlString]
//                    : [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString:error.description];
//
//                [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
//            }];
//        }
//    }];

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
