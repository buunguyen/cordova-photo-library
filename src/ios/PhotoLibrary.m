#import "PhotoLibrary.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Cordova/CDV.h>

@interface PhotoLibrary()

@property (strong, nonatomic) ALAssetsLibrary* library;

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
  NSString* albumName = [command.arguments objectAtIndex:1];
  UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];
  [self save:image albumName:albumName];
}

- (void)save:(UIImage *)image{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)save:(UIImage *)image albumName:(NSString*)albumName
{
    
    self.library = [[ALAssetsLibrary alloc] init];
    [self.library addAssetsGroupAlbumWithName:albumName resultBlock:^(ALAssetsGroup *group) {
        
        ///checks if group previously created
        if(group == nil){
            
            //enumerate albums
            [self.library enumerateGroupsWithTypes:ALAssetsGroupAlbum
                               usingBlock:^(ALAssetsGroup *g, BOOL *stop)
             {
                 //if the album is equal to our album
                 if ([[g valueForProperty:ALAssetsGroupPropertyName] isEqualToString:albumName]) {
                     
                     //save image
                     [self.library writeImageDataToSavedPhotosAlbum:UIImagePNGRepresentation(image) metadata:nil
                                           completionBlock:^(NSURL *assetURL, NSError *error) {
                                               
                                               //then get the image asseturl
                                               [self.library assetForURL:assetURL
                                                    resultBlock:^(ALAsset *asset) {
                                                        //put it into our album
                                                        [g addAsset:asset];
                                                        [self image:image didFinishSavingWithError:nil contextInfo:nil];
                                                    } failureBlock:^(NSError *error) {
                                                        [self image:image didFinishSavingWithError:error contextInfo:nil];
                                                    }];
                                           }];
                     
                 }
             }failureBlock:^(NSError *error){
                 [self image:image didFinishSavingWithError:error contextInfo:nil];
             }];
            
        }else{
            // save image directly to library
            [self.library writeImageDataToSavedPhotosAlbum:UIImagePNGRepresentation(image) metadata:nil
                                  completionBlock:^(NSURL *assetURL, NSError *error) {
                                      
                                      [self.library assetForURL:assetURL
                                           resultBlock:^(ALAsset *asset) {
                                               
                                               [group addAsset:asset];
                                               [self image:image didFinishSavingWithError:nil contextInfo:nil];
                                               
                                           } failureBlock:^(NSError *error) {
                                               [self image:image didFinishSavingWithError:error contextInfo:nil];
                                           }];
                                  }];
        }
        
    } failureBlock:^(NSError *error) {
        [self image:image didFinishSavingWithError:error contextInfo:nil];
    }];
    
    
 // UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
  CDVPluginResult* result = error == NULL
    ? [CDVPluginResult resultWithStatus: CDVCommandStatus_OK]
    : [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString:error.description];

  [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
}

- (void)dealloc
{
  [callbackId release];
  [super dealloc];
}

@end
