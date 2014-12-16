//
//  SYNViewController.m
//  SYNPhotoPicker
//
//  Created by Timothy Johnson on 12/15/2014.
//  Copyright (c) 2014 Timothy Johnson. All rights reserved.
//

#import "SYNViewController.h"
#import <SYNPhotoPicker/SYNPhotoPickerViewController.h>

@interface SYNViewController ()

@end

@implementation SYNViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    SYNPhotoPickerViewController *picker = [[SYNPhotoPickerViewController alloc] initWithTitle:@"NEW TITLE"
                                                                                       options:SYNPhotoPickerCameraRoll | SYNPhotoPickerWebSearch];
    
    [picker setFinalizationBlock:^(SYNPhotoPickerViewController *picker, NSError *err, NSArray *data) {
        if (err) {
            NSLog(@"Error: %@", err.localizedDescription);
            return;
        }
        
        NSLog(@"Returned values: %@", data);
        
        [picker dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [picker setWebsearchBlock:^(NSString *searchText) {
        // Use this area to connect your web search service
        NSLog(@"Searching web for %@", searchText);
    }];
    
    // Pass the results of your webservice search results to the picker
    [self addImages:@[@"http://www.syntertainment.com/img/splash-logo.png"] toPicker:picker forOption:SYNPhotoPickerWebSearch];
    
    
    // Change the Text and image for an option
    [picker customTitle:@"CAMERA" customImage:[UIImage imageNamed:@"editor-camera-tool-black.png"] forOption:SYNPhotoPickerCameraRoll];
    
    // Display the controller
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)addImages:(NSArray *)images toPicker:(SYNPhotoPickerViewController *)picker forOption:(SYNPhotoPickerOptions)option
{
    [picker addImageURLs:images forOption:option];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
