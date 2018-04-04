//
//  RCTB64ImageAsset.m
//  RCTB64ImageAsset
//
//  Created by Sebastien ZINCK on 04/04/2018.
//  Copyright © 2018 Sebastien ZINCK. All rights reserved.
//

#import "RCTB64ImageAsset.h"
#import <Photos/Photos.h>

static NSString *const kErrorNoAssetWithIdentifier = @"E_NO_ASSET_WITH_IDENTIFIER";
static NSString *const kErrorMediaSubtypeNotHandled = @"E_MEDIA_SUBTYPE_NOT_HANDLED";
static NSString *const kErrorUnableToWriteAsset = @"E_UNABLE_TO_WRITE_ASSET";
static NSString *const kErrorLivePhotoRessourceImageNotFound = @"E_LIVE_PHOTO_RESSOURCE_IMAGE_NOT_FOUND";
static NSString *const kErrorNotAnImage = @"E_NOT_AN_IMAGE";


@interface RCTB64ImageAsset()

@property (nonatomic) RCTPromiseResolveBlock resolver;
@property (nonatomic) RCTPromiseRejectBlock rejecter;

@end



@implementation RCTB64ImageAsset

- (dispatch_queue_t)methodQueue
{
    return dispatch_queue_create("RCTB64ImageAssetQueue", DISPATCH_QUEUE_SERIAL);
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(readB64Image:(NSString *)localidentifier resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    self.rejecter = reject;
    self.resolver = resolve;
    
    NSArray *identifiers = [[NSArray alloc] initWithObjects:localidentifier, nil];
    PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:identifiers options:nil];
    
    PHAsset *asset  = [assetsFetchResult firstObject];
    
    if(!asset){
        return [self rejectAndReset:kErrorNoAssetWithIdentifier withMessage:@"Asset not found" withError:nil];
    }
    
    if(asset.mediaType != PHAssetMediaTypeImage){
        return [self rejectAndReset:kErrorNotAnImage withMessage:@"Not an image" withError:nil];
    }
    
    switch(asset.mediaSubtypes){
        case PHAssetMediaSubtypePhotoLive:
            [self handleLivePhoto:asset];
            break;
        case PHAssetMediaSubtypeNone:
            [self handlePhoto:asset];
            break;
        case PHAssetMediaSubtypePhotoHDR:
            [self handlePhoto:asset];
            break;
        case PHAssetMediaSubtypePhotoScreenshot:
            [self handlePhoto:asset];
            break;
        default:
            return [self rejectAndReset:kErrorMediaSubtypeNotHandled withMessage:[NSString stringWithFormat:@"UNKNOWN %ld",(long)asset.mediaSubtypes] withError:nil];
            break;
    }
}

-(void)handlePhoto:(PHAsset*) asset
{
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.synchronous = YES;
    options.version = PHImageRequestOptionsVersionCurrent;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        self.resolver([imageData base64EncodedStringWithOptions:0]);
    }];
}

-(void)handleLivePhoto:(PHAsset*) asset
{
    NSArray *resourcesArray = [PHAssetResource assetResourcesForAsset:asset];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == %ld", PHAssetResourceTypePhoto];
    NSArray *filteredArray = [resourcesArray filteredArrayUsingPredicate:predicate];
    NSString* filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",[NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]]]];
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    PHAssetResource *assetRes  = [filteredArray firstObject];
    
    if(assetRes){
        [[PHAssetResourceManager defaultManager] writeDataForAssetResource:assetRes toFile:fileUrl options:nil completionHandler:^(NSError * _Nullable error) {
            if (error) {
                [self rejectAndReset:kErrorUnableToWriteAsset withMessage:fileUrl.path withError:error];
            }else{
                NSData *data = [NSData dataWithContentsOfURL:fileUrl];
                UIImage *image = [UIImage imageWithData:data];
                NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
                self.resolver([imageData base64EncodedStringWithOptions:0]);
            }
        }];
    }else{
        [self rejectAndReset:kErrorLivePhotoRessourceImageNotFound withMessage:@"" withError:nil];
    }
}

- (void)rejectAndReset: (NSString*) code withMessage: (NSString*) message withError: (NSError*) error
{
    if (self.rejecter) {
        self.rejecter(code, message, error);
    }
}

@end
