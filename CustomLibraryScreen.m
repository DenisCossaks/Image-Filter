//
//  CustomLibraryScreen.m

//Created by Leonardo Leffa on 04/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.


#import "CustomLibraryScreen.h"
#import "CustomLibrary.h"
#import "CustomCell.h"


BOOL isDetailOrTrash;
BOOL isImaheEditable;
@implementation CustomLibraryScreen


@synthesize imageTable;
@synthesize activityIndicator;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {       
		//self.title = NSLocalizedString(@"Home Screen", @"Home Title"); 
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
	
	UIBarButtonItem *rightNavigationBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(actionOnRightNavigationItem:)];
	[self.navigationItem setRightBarButtonItem:rightNavigationBarButtonItem];
	
    imageTable.delegate = self;
    imageTable.dataSource = self;
    [self.imageTable setBackgroundColor:[UIColor clearColor]];
    [self.imageTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.navigationItem.title = @"CustomLibrary";
    toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 373, 320, 45)];
    [toolBar setBarStyle:UIBarStyleBlackTranslucent];
    
	UIBarButtonItem *Share = [[UIBarButtonItem alloc] initWithTitle:@"share" style:UIBarButtonItemStyleBordered target:self action:@selector(share:)];
	//[Share setImage:[UIImage imageNamed:@"Share.png"]];
	
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *Delete = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStyleBordered target:self action:@selector(selectionBtnClicked)];
	//[Delete setImage:[UIImage imageNamed:@"Delete.png"]];
    
    NSArray *toolbarItems = [[NSArray alloc] initWithObjects:Share,flexSpace,Delete,nil];
    [toolBar setItems:toolbarItems];
	
	[toolBar setAlpha:0];
	[toolBar setUserInteractionEnabled:NO];
	
    [self.view addSubview:toolBar];
	[self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    
    imageNameDic = [[NSMutableDictionary alloc]init];
    //Do any additional setup after loading the view from its nib.
}

-(void)share:(id) sender{
	shareActionSheet=[[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Share to FaceBook" otherButtonTitles:nil];
	shareActionSheet.delegate=self;
	[shareActionSheet showInView:self.view];   
}

-(void)actionOnRightNavigationItem:(id)sender{
	if (!isImaheEditable && [imageArray count]>0) {
		isImaheEditable=YES;
	}else {
		isImaheEditable=NO;
	}
	
	if (isImaheEditable) {
		[toolBar setAlpha:0.5];
		[toolBar setUserInteractionEnabled:NO];
	}else {
		[toolBar setAlpha:0];
		[toolBar setUserInteractionEnabled:NO];
	}
	
}

-(void)viewWillAppear:(BOOL)animated{
    imageArray = [CustomLibrary getImageFromLibrary:@"instagramImageFilterApp"];
    [imageTable reloadData];
}

-(void)selectionBtnClicked{
	deleateActionSheet=[[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
	deleateActionSheet.delegate=self;
	[deleateActionSheet showInView:self.view];    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet== deleateActionSheet) {
		if (buttonIndex == 0) {
			//Call Delete Method
			[self performSelector:@selector(deleteBtnClicked)];
		}
    }else {
		if (buttonIndex == 0) {
			
			[[FacebookController sharedController]setDelegate:self];
     		[[FacebookController sharedController]login];
		}
	}
}

#pragma mark Facebook delegates
-(void) facebookDidLoginSuccessfully:(BOOL)successfully{
		NSMutableDictionary *imageDic= [[NSMutableDictionary alloc] init];
	NSLog(@"login success");
	if (successfully==YES) {
		if([imageArray count]>0)
		{
			NSArray *array=[imageNameDic allKeys];
			for (int i=0; i<[array count]; i++) {
				UIImage *image=[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@",[imageArray objectAtIndex:i]]];
				NSData *data= UIImagePNGRepresentation(image);  
				[imageDic setObject:data forKey:@"picture"];
				[imageDic setObject:@"Image shared" forKey:@"description"];
				[[FacebookController sharedController] publishStream:imageDic];	
               if(![activityIndicator isAnimating])
               {
                  [activityIndicator  startAnimating];
               }
			}
		}
		[imageDic release];
	}
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
    [[FacebookController sharedController]logout];
    [activityIndicator  stopAnimating];

}


-(void) facebookDidCloseErrorAlert{
	
}

-(void) facebookDidGetPic:(NSData*)pic successfully:(BOOL)successfully{
	
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (([imageArray count] !=0) && ([imageArray count]%3)==0) {
		return ([imageArray count]/3);
	}else if ([imageArray count] !=0 &&  ([imageArray count]%3)!=0) {
		return ([imageArray count]/3)+1;
	} else {
		return 1;
	}        
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    CustomCell *cell = (CustomCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
	// NSLog(@"image Array := %d",[imageArray count]);
    if ([imageArray count]==0) {
        cell.textLabel.text = @" No image in Custom Library....";
		[cell.textLabel setFont:[UIFont fontWithName:@"Arial" size:16.0]];
        [cell.image1 setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [cell.image1 setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        
        [cell.image2 setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [cell.image2 setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        
        [cell.image3 setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [cell.image3 setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
		
    }else if ([imageArray count] !=0){
		if (((indexPath.row*3)+0)<[imageArray count]) {
			cell.textLabel.text = @"";
            [cell.image1 setBackgroundImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@",[imageArray objectAtIndex:((indexPath.row*3))]]] forState:UIControlStateNormal];
		    [cell.image1 addTarget:self action:@selector(imageDetail:) forControlEvents:UIControlEventTouchUpInside ];
            [cell.image1 setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
            cell.image1.tag = indexPath.row*3;
		}else {
            [cell.image1 setBackgroundColor:[UIColor clearColor]];
            [cell.image1 setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
            [cell.image1 setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
		}
        
        if (((indexPath.row*3)+1)<[imageArray count] ) {
            [cell.image2 setBackgroundImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@",[imageArray objectAtIndex:((indexPath.row*3+1))]]] forState:UIControlStateNormal];
            [cell.image2 addTarget:self action:@selector(imageDetail:) forControlEvents:UIControlEventTouchUpInside ];
            [cell.image2 setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
			cell.image2.tag = indexPath.row*3+1;
        }else {
            [cell.image2 setBackgroundColor:[UIColor clearColor]];
            [cell.image2 setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
            [cell.image2 setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        }
        
        if (((indexPath.row*3)+2)<[imageArray count]) {                    
            [cell.image3 setBackgroundImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@",[imageArray objectAtIndex:((indexPath.row*3+2))]]] forState:UIControlStateNormal];
            [cell.image3 addTarget:self action:@selector(imageDetail:) forControlEvents:UIControlEventTouchUpInside ];
			[cell.image3 setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
			cell.image3.tag = indexPath.row*3+2;
        }else {
            [cell.image3 setBackgroundColor:[UIColor clearColor]];
            [cell.image3 setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
            [cell.image3 setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

-(void)imageDetail:(id)sender{
	
    UIButton *imgBtn = (UIButton*)sender;
    if (isImaheEditable) {
		
		if ([imageArray count]>0) {
			if (![imageNameDic objectForKey:[NSString stringWithFormat:@"%d",imgBtn.tag]]||[[imageNameDic objectForKey:[NSString stringWithFormat:@"%d",imgBtn.tag]] isEqual:@""]) {
				[imageNameDic setObject:[NSString stringWithFormat:@"%@",[imageArray objectAtIndex:imgBtn.tag]] forKey:[NSString stringWithFormat:@"%d",imgBtn.tag]];
				[imgBtn setImage:[UIImage imageNamed:@"Btn_Overlay.png"] forState:UIControlStateNormal];
			}else{
				[imgBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
				//[imageNameDic setObject:@"" forKey:[NSString stringWithFormat:@"%d",imgBtn.tag]];   
				[imageNameDic removeObjectForKey:[NSString stringWithFormat:@"%d",imgBtn.tag]];
			}
		}
		if ([imageNameDic count]==0) {
			[toolBar setAlpha:.5];
			[toolBar setUserInteractionEnabled:NO];
		}else {
			[toolBar setAlpha:1.0];
			[toolBar setUserInteractionEnabled:YES];
		}
	}
}

-(void)addToolBarForDeleteOption{
    toolBarForDelete = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
    [toolBarForDelete setBarStyle:UIBarStyleBlackTranslucent];
    UIBarButtonItem *flexSpace1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *cancleBtn = [[UIBarButtonItem alloc]initWithTitle:@"cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancelSelectionClicked)];
	
    UIBarButtonItem *deleteBtn = [[UIBarButtonItem alloc] initWithTitle:@"delete" style:UIBarButtonItemStyleDone target:self action:@selector(deleteBtnClicked)];
	
    NSArray *toolbarItems = [[NSArray alloc] initWithObjects:deleteBtn,flexSpace1,cancleBtn,nil];
    toolBarForDelete.items = toolbarItems;
    [self.view addSubview:toolBarForDelete];
}
-(void) dealloc{
	[imageTable release];
	imageTable=nil;
	
	[imageArray release];
	imageArray=nil;
	
    [toolBar release];
	toolBar=nil;
	
    [imageNameDic release];
	imageNameDic=nil;
	
   // [toolBarForDelete release];
	toolBarForDelete=nil;
	
	[deleateActionSheet release];
	deleateActionSheet=nil;
	
	[shareActionSheet release];
	shareActionSheet=nil;
	[super dealloc];
}
-(void)cancelSelectionClicked{
    toolBar.hidden = NO;
    isDetailOrTrash = NO;
    [toolBarForDelete removeFromSuperview];
    [imageNameDic removeAllObjects];
    [imageTable reloadData];
}

-(void)deleteBtnClicked{
    if ([imageNameDic count]>0) {
        [CustomLibrary deleteMultipleImagesFromLibrary:imageNameDic directoryName:@"instagramImageFilterApp"];  
        if ([imageArray count]>0) {
            [imageArray removeAllObjects];
            [imageNameDic removeAllObjects];
        }
        imageArray = [CustomLibrary getImageFromLibrary:@"instagramImageFilterApp"];
        [imageTable reloadData];
    }
	[toolBar setAlpha:0];
	[toolBar setUserInteractionEnabled:NO];
}
- (void)viewDidUnload
{
	isImaheEditable=NO;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
