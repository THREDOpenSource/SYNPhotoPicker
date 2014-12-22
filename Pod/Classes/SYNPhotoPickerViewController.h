//
//  SYNPhotoPickerViewController.h
//  SYNPhotoPicker
//
//  Created by Timothy Johnson on 12/10/14.
//  Copyright (c) 2014 Syntertainment. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, SYNPhotoPickerOptions) {
    /**
     * Enables Camera Roll
     */
    SYNPhotoPickerCameraRoll = 1 << 0,
    
    /**
     * Enables a custom data source
     */
    SYNPhotoPickerCustomDataSource = 1 << 1,
    
    /**
     * Enables Web search results
     */
    SYNPhotoPickerWebSearch = 1 << 2,
};

@protocol SYNPhotoPickerDelegate <NSObject>

@required
- (void)didSelectItemForIndexPath:(NSIndexPath *)indexpath forOption:(SYNPhotoPickerOptions)option;
- (void)didSelectAssetLibraryURL:(NSString *)assetURL;
- (void)didSearchWithString:(NSString *)search;

@end

@interface SYNPhotoPickerViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITabBarDelegate>

typedef void (^SYNPhotoPickerWebSearchBlock)(NSString *searchText);

@property (nonatomic, assign) id<SYNPhotoPickerDelegate> delegate;

- (id)initWithTitle:(NSString *)title options:(SYNPhotoPickerOptions)options;

- (void)customTitle:(NSString *)title customImage:(UIImage *)image forOption:(SYNPhotoPickerOptions)option;

- (void)addImageURLs:(NSArray *)imageURLs forOption:(SYNPhotoPickerOptions)option;

@end
