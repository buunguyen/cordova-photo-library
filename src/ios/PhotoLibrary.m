
#import "PhotoLibrary.h"
#import <Cordova/CDV.h>
#import <Photos/Photos.h>

@implementation PhotoLibrary

@synthesize callbackId;
@synthesize localId;


- (void)sendResult:(NSString *)assetId {
    CDVPluginResult *result = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsString:assetId];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
}

- (void)sendError:(NSError *)error {
    CDVPluginResult *result = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString:error.description];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
}

- (void)imageFromUrl:(CDVInvokedUrlCommand *) command
{
    [self.commandDelegate runInBackground:^{
        self.callbackId = command.callbackId;
        NSMutableDictionary *options = [command argumentAtIndex:0];
        NSString* url = [options objectForKey:@"url"];
        __block NSString* albumName = nil;
        if (![[options objectForKey:@"albumName"] isEqual:[NSNull null]]) {
            albumName = [options objectForKey:@"albumName"];
        }
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        UIImage *image = [UIImage imageWithData:data];

        [self checkCollection:nil insertImage:image intoAlbumNamed:albumName];
    }];
}

- (void)videoFromUrl:(CDVInvokedUrlCommand *) command
{
    [self.commandDelegate runInBackground:^{
        self.callbackId = command.callbackId;
        NSMutableDictionary *options = [command argumentAtIndex:0];
        NSString* url = [options objectForKey:@"url"];
        __block NSString* albumName = nil;
        if (![[options objectForKey:@"albumName"] isEqual:[NSNull null]]) {
            albumName = [options objectForKey:@"albumName"];
        }
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"file.mov"];
        [data writeToFile:path atomically:YES];
        NSURL *pathUrl = [NSURL fileURLWithPath:path];
        
        [self checkCollection:pathUrl insertImage:nil intoAlbumNamed:albumName];
    }];
}
- (void)checkCollection:(NSURL*)videoUrl insertImage:(UIImage *)image intoAlbumNamed:(NSString *)albumName {
    if (albumName == nil) {
        [self insertAsset:videoUrl insertImage:image intoAssetCollection: nil];
    } else {
        //Fetch a collection in the photos library that has the title "albumName"
        PHAssetCollection *collection = [self fetchAssetCollectionWithAlbumName: albumName];

        if (collection == nil) {
            //If we were unable to find a collection named "albumName" we'll create it before inserting the image
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle: albumName];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                if (error != nil) {
                    NSLog(@"Error inserting media into album: %@", error.localizedDescription);
                    [self sendError:error];
                }

                if (success) {
                    //Fetch the newly created collection (which we *assume* exists here)
                    PHAssetCollection *newCollection = [self fetchAssetCollectionWithAlbumName:albumName];
                    [self insertAsset:videoUrl insertImage:image intoAssetCollection: newCollection];
                }
            }];
        } else {
            //If we found the existing AssetCollection with the title "albumName", insert into it
            [self insertAsset:videoUrl insertImage:image intoAssetCollection: collection];
        }
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

- (void)insertAsset:(NSURL *)videoUrl insertImage:(UIImage *)image intoAssetCollection:(PHAssetCollection *)collection {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        __block PHAssetCreationRequest *creationRequest;
        //This will request a PHAsset be created for the URL
        if(videoUrl != nil) {
            creationRequest = [PHAssetCreationRequest creationRequestForAssetFromVideoAtFileURL:videoUrl];
        } else {
            creationRequest = [PHAssetCreationRequest creationRequestForAssetFromImage:image];
        }

        self.localId = [[creationRequest placeholderForCreatedAsset] localIdentifier];

        if(collection != nil) {
            //Create a change request to insert the new PHAsset in the collection
            PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
            //Add the PHAsset placeholder into the creation request.
            //The placeholder is used because the actual PHAsset hasn't been created yet
            if (request != nil && creationRequest.placeholderForCreatedAsset != nil) {
                [request addAssets: @[creationRequest.placeholderForCreatedAsset]];
            }
        }

    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error inserting image into asset collection: %@", error.localizedDescription);
            [self sendError:error];
        }
        if (success){
            [self sendResult:self.localId];
        }
    }];
}


- (void)dealloc
{
    [callbackId release];
    [super dealloc];
}

@end
