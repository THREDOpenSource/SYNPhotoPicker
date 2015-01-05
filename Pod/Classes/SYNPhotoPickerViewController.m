//
//  SYNPhotoPickerViewController.m
//  SYNPhotoPicker
//
//  Created by Timothy Johnson on 12/10/14.
//  Copyright (c) 2014 Syntertainment. All rights reserved.
//

#import "SYNPhotoPickerViewController.h"
#import "SYNSearchCell.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <SDWebImage/UIImageView+WebCache.h>

#pragma mark - SYNAssetImageData

@interface SYNAssetImageData: NSObject

@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation SYNAssetImageData
@end

#pragma mark - SYNPhotoPickerViewController

@interface SYNPhotoPickerViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *pickerTitle;
@property (weak, nonatomic) IBOutlet UITabBar *pickerTabBar;
@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UILabel *noResultsLabel;

@end

@implementation SYNPhotoPickerViewController {
    // Pod Bundle
    NSBundle *podBundle;
    
    // Picker options
    SYNPhotoPickerOptions currentOptions;
    
    // Picker Mode
    unsigned long mode;
    
    // Picker Mapping
    NSMutableDictionary *mapping;
    
    // UICollectionView arrays (Dictionary of arrays)
    NSMutableDictionary *content;
}

@synthesize delegate;

#pragma mark - Initialization

- (id)init
{
    if (self == [super self]) {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"SYNPhotoPicker" ofType:@"bundle"];
        podBundle = [NSBundle bundleWithPath:bundlePath];
        
        self = [self initWithNibName:@"SYNPhotoPickerViewController" bundle:podBundle];
        [self.view addSubview:[[[UINib nibWithNibName:@"SYNPhotoPickerViewController" bundle:podBundle] instantiateWithOwner:self options:nil] objectAtIndex:0]];
    }
    
    return self;
}

- (id)initWithTitle:(NSString *)title options:(SYNPhotoPickerOptions)options
{
    if (self == [super self]) {
        self = [self init];
        
        [self.pickerTitle setText:title];
        
        currentOptions = options;
        
        mapping = NSMutableDictionary.new;
        content = NSMutableDictionary.new;
        
        NSMutableArray *pickerItems = NSMutableArray.new;
        
        if (currentOptions & SYNPhotoPickerCameraRoll) {
            UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:@"PHOTOS" image:[UIImage imageNamed:@"camera-cameraroll.png"
                                                                                                  inBundle:podBundle
                                                                             compatibleWithTraitCollection:nil]
                                                                   tag:SYNPhotoPickerCameraRoll];
            
            [pickerItems addObject:item];
            [mapping setObject:[NSNumber numberWithLong:pickerItems.count-1] forKey:[NSNumber numberWithInt:SYNPhotoPickerCameraRoll]];
            
            [content setObject:NSMutableArray.new forKey:[NSString stringWithFormat:@"%lu", (unsigned long)SYNPhotoPickerCameraRoll]];
            
            [self loadPhotosFromAssetGroup];
        }
        
        if (currentOptions & SYNPhotoPickerCustomDataSource) {
            UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:@"CUSTOM" image:[UIImage imageNamed:@"camera-cameraroll.png"
                                                                                                  inBundle:podBundle
                                                                             compatibleWithTraitCollection:nil]
                                                                   tag:SYNPhotoPickerCustomDataSource];
            
            [pickerItems addObject:item];
            [mapping setObject:[NSNumber numberWithLong:pickerItems.count-1] forKey:[NSNumber numberWithInt:SYNPhotoPickerCustomDataSource]];
            
            [content setObject:NSMutableArray.new forKey:[NSString stringWithFormat:@"%lu", (unsigned long)SYNPhotoPickerCustomDataSource]];
        }
        
        if (currentOptions & SYNPhotoPickerWebSearch) {
            UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:@"SEARCH" image:[UIImage imageNamed:@"editor-search.png"
                                                                                                  inBundle:podBundle
                                                                             compatibleWithTraitCollection:nil]
                                                                   tag:SYNPhotoPickerWebSearch];
            
            [pickerItems addObject:item];
            [mapping setObject:[NSNumber numberWithLong:pickerItems.count-1] forKey:[NSNumber numberWithInt:SYNPhotoPickerWebSearch]];
            
            [content setObject:NSMutableArray.new forKey:[NSString stringWithFormat:@"%lu", (unsigned long)SYNPhotoPickerWebSearch]];
        }
        
        [self.pickerTabBar setItems:pickerItems];
    }
    
    self.noResultsLabel.hidden = YES;
    
    return self;
}

- (void)customTitle:(NSString *)title customImage:(UIImage *)image forOption:(SYNPhotoPickerOptions)option
{
    UITabBarItem *item = [self.pickerTabBar.items objectAtIndex:[[mapping objectForKey:[NSNumber numberWithLong:option]] intValue]];
    item.title = title;
    item.image = image;
    item.selectedImage = image;
}

#pragma mark - UIViewController Delegates

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"SYNPhotoPicker" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    [self.collectionView registerNib:[UINib nibWithNibName:@"SYNSearchCell" bundle:bundle] forCellWithReuseIdentifier:@"SYNPhotoPickerCell"];
    
    mode = currentOptions & SYNPhotoPickerCameraRoll ?: currentOptions & SYNPhotoPickerWebSearch ?: currentOptions & SYNPhotoPickerCustomDataSource;
    
    [self.pickerTabBar setSelectedItem:[self.pickerTabBar.items objectAtIndex:[[mapping objectForKey:[NSNumber numberWithLong:mode]] intValue]]];
    
    [self toggleSearchBarVisibility];
}

#pragma mark - UICollectionView Delegates

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[content valueForKey:[NSString stringWithFormat:@"%lu", mode]] count];
}

- (SYNSearchCell *)photoImageForCellAt:(NSIndexPath *)indexPath
{
    SYNSearchCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"SYNPhotoPickerCell" forIndexPath:indexPath];
    
    NSArray *photoArray = [content objectForKey:[NSString stringWithFormat:@"%lu", (unsigned long)SYNPhotoPickerCameraRoll]];
    
    SYNAssetImageData *data = (SYNAssetImageData *)photoArray[indexPath.row];
    cell.imageView.image = data.imageView.image;
    
    return cell;
}

- (SYNSearchCell *)imageForCellAt:(NSIndexPath *)indexPath withOption:(SYNPhotoPickerOptions)option
{
    SYNSearchCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"SYNPhotoPickerCell" forIndexPath:indexPath];

    NSArray *imageArray = [content objectForKey:[NSString stringWithFormat:@"%lu", (unsigned long)option]];
    
    [cell.imageView sd_setImageWithURL:imageArray[indexPath.row]
                      placeholderImage:[UIImage imageNamed:@"editor-placeholder-1.png"
                                                  inBundle:podBundle
                             compatibleWithTraitCollection:nil]
                               options:kNilOptions];
    return cell;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)curCollectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SYNSearchCell *cell;
    
    switch (mode) {
        case SYNPhotoPickerCameraRoll:
            cell = [self photoImageForCellAt:indexPath];
            break;
        case SYNPhotoPickerCustomDataSource:
            cell = [self imageForCellAt:indexPath withOption:SYNPhotoPickerCustomDataSource];
            break;
        case SYNPhotoPickerWebSearch:
            cell = [self imageForCellAt:indexPath withOption:SYNPhotoPickerWebSearch];
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (mode) {
        case SYNPhotoPickerCameraRoll:
            [self didSelectCameraRoll:indexPath];
            break;
        case SYNPhotoPickerCustomDataSource:
            [self didSelectItem:indexPath forOption:SYNPhotoPickerCustomDataSource];
            break;
        case SYNPhotoPickerWebSearch:
            [self didSelectItem:indexPath forOption:SYNPhotoPickerWebSearch];
            break;
        default:
            break;
    }
}

- (void)didSelectCameraRoll:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
        return;
    }
    
    NSArray *photoArray = [content objectForKey:[NSString stringWithFormat:@"%lu", (unsigned long)SYNPhotoPickerCameraRoll]];
    SYNAssetImageData *data = (SYNAssetImageData *)photoArray[indexPath.row];
    
    [delegate didSelectAssetLibraryURL:[NSString stringWithFormat:@"%@", data.url]];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didSelectItem:(NSIndexPath *)indexPath forOption:(SYNPhotoPickerOptions)option
{
    [self.delegate didSelectItemForIndexPath:indexPath forOption:option];
}

#pragma mark - TabBar delegates

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (mode == item.tag)
        return;
    
    mode = item.tag;
    
    [self toggleSearchBarVisibility];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

#pragma mark - Searchbar delegates

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    [self.delegate didSearchWithString:searchBar.text];
}

- (void)toggleSearchBarVisibility
{
    if (mode == SYNPhotoPickerWebSearch)
        self.searchView.hidden = NO;
    else
        self.searchView.hidden = YES;
}

#pragma mark - Image Picker delegates

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *pickedImage = info[UIImagePickerControllerOriginalImage];
    
    // Dismiss the imagePickerController and go back the the Editor view
    [picker dismissViewControllerAnimated:YES completion:^{
        
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            // Request to save the image to camera roll
            ALAssetsLibrary *library = ALAssetsLibrary.new;
            [library writeImageToSavedPhotosAlbum:pickedImage.CGImage
                                                             orientation:(ALAssetOrientation)pickedImage.imageOrientation
                                                         completionBlock:^(NSURL *assetURL, NSError *error)
             {
                 if (error) {
                     NSLog(@"SYNPhotoPickerViewController: Error accessing image: %@", error.localizedDescription);
                     return;
                 }
                 
                 // Photo was taken
                 [self.delegate didSelectAssetLibraryURL:[NSString stringWithFormat:@"%@", assetURL]];
             }];
        } else {
            [picker dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    if (sourceType == UIImagePickerControllerSourceTypeCamera &&
        (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]))
    {
        UIAlertView *alert = [UIAlertView.alloc
                              initWithTitle:@"Camera"
                              message:@"This device doesn't have a camera."
                              delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    UIImagePickerController *imagePickerController = UIImagePickerController.alloc.init;
    imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        imagePickerController.showsCameraControls = YES;
    }
    
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark - Load Photo Assets

- (void)loadPhotosFromAssetGroup
{
    ALAssetsLibrary *library = ALAssetsLibrary.new;
    __block NSMutableArray *photoArray = [content objectForKey:[NSString stringWithFormat:@"%lu", (unsigned long)SYNPhotoPickerCameraRoll]];
    
    SYNAssetImageData *cameraButton = SYNAssetImageData.alloc.init;
    cameraButton.imageView = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"editor-camera-tool-black.png" inBundle:podBundle compatibleWithTraitCollection:nil]];
    [photoArray addObject:cameraButton];
    
    [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (!group)
            return;
        
        [self addPhotosFromAssetGroup:group toArray:photoArray];
        
    } failureBlock:^(NSError *error) {
        NSLog(@"SYNPhotoPickerViewController: Error loading photos: %@", error.localizedDescription);
    }];
}

- (void)addPhotosFromAssetGroup:(ALAssetsGroup *)group toArray:(NSMutableArray *)photoArray
{
    [group setAssetsFilter:ALAssetsFilter.allPhotos];
    
    [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (!result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
            return;
        }
        
        // Add result to array
        SYNAssetImageData *data = SYNAssetImageData.alloc.init;
        data.url = result.defaultRepresentation.url;
        data.imageView = [[UIImageView alloc] initWithImage:[UIImage.alloc initWithCGImage:result.thumbnail]];
        
        [photoArray addObject:data];
    }];
}

#pragma mark - Insert image data

- (void)addImageURLs:(NSArray *)imageURLs forOption:(SYNPhotoPickerOptions)option
{
    if (option == SYNPhotoPickerCameraRoll)
        return;
    
    [content setObject:imageURLs forKey:[NSString stringWithFormat:@"%lu", (unsigned long)option]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
        self.noResultsLabel.hidden = imageURLs.count > 0;
    });
}

#pragma mark - IBActions

- (IBAction)backButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
