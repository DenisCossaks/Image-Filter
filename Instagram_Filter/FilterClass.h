//
//  FilterClass.h
//  Instagram_Filter
//
//  Created by Zoo on 09/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterClass : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
          UIImagePickerController * imagePicker;


}

@property (retain, nonatomic) IBOutlet UIButton *pickPhotoBtn;
@property (retain, nonatomic) IBOutlet UIButton *tackPhotoBtn;

- (IBAction)showCam:(UIButton *)sender;


@end
