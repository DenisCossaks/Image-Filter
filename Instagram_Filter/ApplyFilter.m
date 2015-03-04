//
//  ApplyFilter.m
//  Instagram_Filter
//
//  Created by Zoo on 09/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ApplyFilter.h"

#import "UIImage+FiltrrCompositions.h"
#import "UIImage+Resize.h"
#import "UIImage+Filter.h"

#import "CustomLibrary.h"

@implementation ApplyFilter
@synthesize ImgView,imageFilter,imageOrg,scrollForButton,Indicator;

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
{//Test0.png

    [super viewDidLoad];

    ImgView.image=imageOrg;
    [self hideIndicator];
    scrollForButton=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 325, 320, 115)];
    [scrollForButton setContentSize:CGSizeMake(2085, 80)];
    [self.view addSubview:scrollForButton];
    NSArray *array=[[NSArray alloc] initWithObjects:@"Normal",@"X-Pro II",@"Lomo-fi",@"Earlybird",@"Sutro",@"Toaster",@"Inkwell",@"Walden",@"Hefe",@"Apollo",@"Poprocket",@"Nashville",@"Gotham",@"1977",@"Kelvin",@"Terrer",@"Chuiii",@"Khuii",@"Suii",@"LapadGhandis",@"kupera",@"Luserewa",@"Rwtesa",@"Wqadswa",@"Loufg",@"Trcga", nil];

    int width=5;
    for (int i=0; i<26; i++) {
        UIButton *btn=[[UIButton alloc] initWithFrame:CGRectMake(width, 5, 70, 70)];
        [btn setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"Test%d.png",i]] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(actionOnButton:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag=i;
        [scrollForButton addSubview:btn];
        
        UILabel *lbl=[[UILabel alloc] initWithFrame:CGRectMake(width, 67, 70, 30)];
        [lbl setBackgroundColor:[UIColor clearColor]];
        [lbl setFont:[UIFont boldSystemFontOfSize:12]];
        [lbl setTextAlignment:UITextAlignmentCenter];
        [lbl setTextColor:[UIColor darkGrayColor]];
        [lbl setText:[array objectAtIndex:i]];
        [scrollForButton addSubview:lbl];
        
        width=width+80;
    }
    //UIBarButtonItem *righrBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveToLocalDictionary:)];
    UIBarButtonItem *righrBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Option" style:UIBarButtonItemStyleDone target:self action:@selector(saveToLocalDictionary:)];
    [self.navigationItem setRightBarButtonItem:righrBarButtonItem];
    // Do any additional setup after loading the view from its nib.
}
-(void)saveToLocalDictionary:(id) sender{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"Photo Options"
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:@"Share Photo And Save"
                                  otherButtonTitles:@"Save Photo",@"Share Photo",nil];
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    [actionSheet release];
//    UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"Message" message:@"Do you want to save this picture in app's local Library ?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
//    [alertView show];
//    [alertView release]; 
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];  
    
    if([title isEqualToString:@"Cancel"]){  
    }
    
    	
	    
    if([title isEqualToString:@"Share Photo And Save"]){  
        [self showIndicator];
        UIImageWriteToSavedPhotosAlbum(ImgView.image, nil, nil, nil);

		[[FacebookController sharedController]setDelegate:self];
        [[FacebookController sharedController]login];
        //[self performSelector:@selector(showPicker:)];
	}
    if([title isEqualToString:@"Save Photo"]){  
		UIImageWriteToSavedPhotosAlbum(ImgView.image, nil, nil, nil);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Image saved in camera roll successfully." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	}
    
    
    if([title isEqualToString:@"Share Photo"]){  
        [self showIndicator];
		[[FacebookController sharedController]setDelegate:self];
        [[FacebookController sharedController]login];
        //[self performSelector:@selector(showPicker:)];
	}
    
}

//---- faceBook Deliafate--------
#pragma mark Facebook delegates
-(void) facebookDidLoginSuccessfully:(BOOL)successfully{
    
    NSMutableDictionary *imageDic= [[NSMutableDictionary alloc] init];
                NSData *data= UIImagePNGRepresentation(ImgView.image);  
				[imageDic setObject:data forKey:@"picture"];
				[imageDic setObject:@"Image shared" forKey:@"description"];
				[[FacebookController sharedController] publishStream:imageDic];	
		[imageDic release];
}

-(void) facebookDidGetUid:(NSString*)uid successfully:(BOOL)successfully{
	
}

-(void) facebookDidGetFiends:(NSArray*)friends successfully:(BOOL)successfully{
	
}

-(void) facebookDidPublishSuccessfully:(BOOL)successfully{
	if (successfully) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Image posted successfully." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	}else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Error posting image on facebook" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	}	
    [self hideIndicator];
    [[FacebookController sharedController]logout];
}


-(void) facebookDidCloseErrorAlert{
	
}

-(void) facebookDidGetPic:(NSData*)pic successfully:(BOOL)successfully{
	
}

//------ FaceBook Deligate-----------

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex{    NSString *buttonTitle=[alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Save"]) {
        UIImageWriteToSavedPhotosAlbum(ImgView.image, nil, nil, nil);
        [self.navigationController popToRootViewControllerAnimated:YES];
//        [CustomLibrary createDirectory:@"instagramImageFilterApp"];
//        [CustomLibrary saveImageInLibrary:ImgView.image imageName:@"" directoryName:@"instagramImageFilterApp"];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
-(void)showIndicator{
    [self.view setUserInteractionEnabled:NO];
    [Indicator setHidden:NO];
    [Indicator startAnimating];
}
-(void)hideIndicator{
    [self.view setUserInteractionEnabled:YES];
    [Indicator setHidden:YES];
    [Indicator stopAnimating];
}
-(IBAction)actionOnButton:(id)sender{
    UIButton *btn=(UIButton *)sender;
    int tag=btn.tag;
    [self showIndicator];
    
    [self performSelector:@selector(callFilter:) withObject:[NSString stringWithFormat:@"%d",tag] afterDelay:0.2];
    
    //ImgView.image=[self filteredImageWithImage:imageOrg filter:tag];
    
//    NSString  *pngPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/Test%d.png",tag]];
//    
//    UIImage *image=[ImgView.image thumbnailImage:180 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationHigh];
//    // Write image to PNG
//    [UIImagePNGRepresentation(image) writeToFile:pngPath atomically:YES];
    
}
-(void)callFilter:(NSString *)tag{

   ImgView.image=[self filteredImageWithImage:imageOrg filter:[tag intValue]];
    [self hideIndicator];
}
- (UIImage *) filteredImageWithImage:(UIImage *)image filter:(int)filterCase{

    switch (filterCase) {
        case 0:{
            SEL _track = NSSelectorFromString(@"trackTime:");
            return [image performSelector:_track withObject:@"e00"];
            break;
        }
        case 1:{
            SEL _track = NSSelectorFromString(@"trackTime:");
            return [image performSelector:_track withObject:@"e01"];
           break;
        }
        case 2:{
            SEL _track = NSSelectorFromString(@"trackTime:");
            return [image performSelector:_track withObject:@"e02"];
            break;
        }
        case 3:{
            SEL _track = NSSelectorFromString(@"trackTime:");
            return [image performSelector:_track withObject:@"e03"];
            break;
        }
        case 4:{
            SEL _track = NSSelectorFromString(@"trackTime:");
            return [image performSelector:_track withObject:@"e04"];
            break;
        }
        case 5:{
            SEL _track = NSSelectorFromString(@"trackTime:");
            return [image performSelector:_track withObject:@"e05"];
            break;
        }
        case 6:{
            SEL _track = NSSelectorFromString(@"trackTime:");
            return [image performSelector:_track withObject:@"e06"];
           
            break;
        }
        case 7:{
            SEL _track = NSSelectorFromString(@"trackTime:");
            return [image performSelector:_track withObject:@"e07"];
            break;
        }
        case 8:{
            SEL _track = NSSelectorFromString(@"trackTime:");
            return [image performSelector:_track withObject:@"e08"];
            break;
        }
        case 9:{
            SEL _track = NSSelectorFromString(@"trackTime:");
            return [image performSelector:_track withObject:@"e09"];
            break;
        }
        case 10:{
            SEL _track = NSSelectorFromString(@"trackTime:");
            return [image performSelector:_track withObject:@"e010"];
            break;
            
        }
        case 11:{
            SEL _track = NSSelectorFromString(@"trackTime:");
            return [image performSelector:_track withObject:@"e011"];
            break;
        }
            
        case 12:{
            SEL _track = NSSelectorFromString(@"trackTime:");
            return [image performSelector:_track withObject:@"e012"];
            break;
        }
            
        case 13:{
            SEL _track = NSSelectorFromString(@"trackTime:");
            return [image performSelector:_track withObject:@"e013"];
            break;         
        }
            
        case 14:{
            SEL _track = NSSelectorFromString(@"trackTime:");
            return [image performSelector:_track withObject:@"e014"];
            break;
        }
            
        case 15:{
            
            SEL _track = NSSelectorFromString(@"trackTime:");   
            return [image performSelector:_track withObject:@"e6"];
            break;
            
        }
            
        case 16:{
            
            SEL _track = NSSelectorFromString(@"trackTime:");

            return [image performSelector:_track withObject:@"e2"];
            
            break;
            
        }   
        case 17:{
            
            SEL _track = NSSelectorFromString(@"trackTime:");

            return [image performSelector:_track withObject:@"e7"];
            
            break;
            
        }
            
        case 18:{
            
            SEL _track = NSSelectorFromString(@"trackTime:");

            return [image performSelector:_track withObject:@"e10"];
            
            break;
            
        }
            
            
            
        case 19:{
            
            SEL _track = NSSelectorFromString(@"trackTime:");
            return [image performSelector:_track withObject:@"e12"];
            break;
            
        }
        case 20:{
            
            SEL _track = NSSelectorFromString(@"trackTime:");
           

            return [image performSelector:_track withObject:@"e1"];
            break;
            
        }
        case 21:{
            
            SEL _track = NSSelectorFromString(@"trackTime:");
           

            return [image performSelector:_track withObject:@"e3"];
            break;
            
        }
        case 22:{
            
            SEL _track = NSSelectorFromString(@"trackTime:");
           

            return [image performSelector:_track withObject:@"e4"];
            break;
            
        }
        case 23:{
            
            SEL _track = NSSelectorFromString(@"trackTime:");
           

            return [image performSelector:_track withObject:@"e5"];
            break;
            
        }
        case 24:{
            
            SEL _track = NSSelectorFromString(@"trackTime:");
           

            return [image performSelector:_track withObject:@"e8"];
            break;
            
        }
        case 25:{
            
            SEL _track = NSSelectorFromString(@"trackTime:");
           

            return [image performSelector:_track withObject:@"e9"];
            break;
            
        }
        default:
            return image;
            break;
    }
    return image;
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
