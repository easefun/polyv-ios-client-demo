//
//  PLVAssetData.m
//  PLV-ios-client-demo
//
//  Copyright (c) 2013 Polyv Inc. All rights reserved.
//

#import "PLVKit.h"
#import "PLVAssetData.h"

@interface PLVAssetData ()
@property (strong, nonatomic) ALAsset* asset;
@end

@implementation PLVAssetData

- (id)initWithAsset:(ALAsset*)asset
{
    self = [super init];
    if (self) {
        self.asset = asset;
    }
    return self;
}

#pragma mark - PLVData Methods
- (long long)length
{
    ALAssetRepresentation* assetRepresentation = [_asset defaultRepresentation];
    if (!assetRepresentation) {
        // NOTE:
        // defaultRepresentation "returns nil for assets from a shared photo
        // stream that are not yet available locally." (ALAsset Class Reference)

        // TODO:
        // Handle deferred availability of ALAssetRepresentation,
        // by registering for an ALAssetsLibraryChangedNotification.
        PLVLog(@"@TODO: Implement support for ALAssetsLibraryChangedNotification to support shared photo stream assets");
        return 0;
    }

    return [assetRepresentation size];
}

- (NSUInteger)getBytes:(uint8_t *)buffer
            fromOffset:(long long)offset
                length:(NSUInteger)length
                 error:(NSError **)error
{
    ALAssetRepresentation* assetRepresentation = [_asset defaultRepresentation];
    return [assetRepresentation getBytes:buffer
                              fromOffset:offset
                                  length:length
                                   error:error];
}

@end
