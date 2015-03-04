//
//  HomeViewController.m
//  Instagram_Filter
//
//  Created by Zoo on 09/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HomeViewController.h"
#import "ApplyFilter.h"
#import "UIImage+Resize.h"

#import "CustomLibraryScreen.h"

@implementation HomeViewController
@synthesize pickPhotoBtn,tackPhotoBtn;
@synthesize imageView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=@"Home";
    //self.navigationController.title=@"";
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated{
  self.title=@"Home";

}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
#pragma mark image picker
- (IBAction)showCam:(UIButton *)sender {
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    if (sender == pickPhotoBtn) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    } else {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    [imagePicker setAllowsEditing: YES];
    [self presentModalViewController:imagePicker animated:YES];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *) image editingInfo:(NSDictionary *)editingInfo {
    [picker dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
   // if ( imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImage *image = [[info objectForKey:@"UIImagePickerControllerOriginalImage"] copy];
        ApplyFilter *filObj=[[ApplyFilter alloc] init];
        filObj.imageOrg=[image thumbnailImage:640 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationHigh];
        self.title=@"back";
        [self.navigationController pushViewController:filObj animated:YES];
        [picker dismissModalViewControllerAnimated:YES];
   // }
    
}

-(UIImage *)resizeImage:(UIImage*)image{
    
    UIGraphicsBeginImageContext(CGSizeMake(320, 320));
    [image drawInRect:CGRectMake(0,0,320,320)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)customLibrary:(UIButton *)sender{
    CustomLibraryScreen *obj=[[CustomLibraryScreen alloc] init];
    [self.navigationController pushViewController:obj animated:YES];
    [obj release];
}


@end
