//
//  SYNViewController.m
//  SYNPhotoPicker
//
//  Created by Timothy Johnson on 12/15/2014.
//  Copyright (c) 2014 Timothy Johnson. All rights reserved.
//

#import "SYNViewController.h"

@interface SYNViewController ()

@end

@implementation SYNViewController {
    SYNPhotoPickerViewController *picker;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    picker = [[SYNPhotoPickerViewController alloc] initWithTitle:@"NEW TITLE"
                                                         options:SYNPhotoPickerCameraRoll | SYNPhotoPickerWebSearch];
    picker.delegate = self;
    
    [picker addImageURLs:@[@"http://www.syntertainment.com/img/splash-logo.png"] forOption:SYNPhotoPickerWebSearch];
    
    // Change the Text and image for an option
    [picker customTitle:@"CAMERA" customImage:[UIImage imageNamed:@"editor-camera-tool-black.png"] forOption:SYNPhotoPickerCameraRoll];
    
    // Display the controller
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SYNPhotoPickerDelegates

- (void)didSelectItemForIndexPath:(NSIndexPath *)indexpath forOption:(SYNPhotoPickerOptions)option
{
    NSLog(@"Selected item at index path: %ld", (long)indexpath.row);
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)didSelectAssetLibraryURL:(NSString *)assetURL
{
    NSLog(@"Selected photo with AssetURL: %@", assetURL);
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)didSearchWithString:(NSString *)search
{
    NSLog(@"Searched for string: %@", search);
}

@end
