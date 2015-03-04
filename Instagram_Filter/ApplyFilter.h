//
//  ApplyFilter.h
//  Instagram_Filter
//
//  Created by Zoo on 09/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookController.h"

@interface ApplyFilter : UIViewController<UIAlertViewDelegate,UIActionSheetDelegate,FacebookControllerDelegate>{
    UIImageView *ImgView;
    UIImage *imageOrg;
    UIImage *imageFilter;
    UIScrollView *scrollForButton;
    UIActivityIndicatorView *Indicator;
}
@property(nonatomic,retain)IBOutlet UIActivityIndicatorView *Indicator;
@property(nonatomic,retain)IBOutlet UIImageView *ImgView;
@property(nonatomic,retain) UIImage *imageOrg;
@property(nonatomic,retain) UIImage *imageFilter;
@property(nonatomic,retain) UIScrollView *scrollForButton;

-(void)showIndicator;
-(void)hideIndicator;
- (UIImage *) filteredImageWithImage:(UIImage *)image filter:(int)filterCase;
-(IBAction)actionOnButton:(id)sender;
@end
