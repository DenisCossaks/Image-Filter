//
//  HomeViewController.h
//  Instagram_Filter
//
//  Created by Zoo on 09/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    UIImagePickerController * imagePicker;
    
    UIImageView *imageView;
}
@property(nonatomic,retain)IBOutlet  UIImageView *imageView;
@property (retain, nonatomic) IBOutlet UIButton *pickPhotoBtn;
@property (retain, nonatomic) IBOutlet UIButton *tackPhotoBtn;
-(UIImage *)resizeImage:(UIImage*)image;
- (IBAction)showCam:(UIButton *)sender;
- (IBAction)customLibrary:(UIButton *)sender;

@end
