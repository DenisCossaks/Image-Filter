
//Created by Leonardo Leffa on 04/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookController.h"


@interface CustomLibraryScreen : UIViewController<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,FacebookControllerDelegate> {
	UITableView *imageTable;
    NSMutableArray *imageArray;
    UIToolbar *toolBar;
    NSMutableDictionary *imageNameDic;
    UIToolbar *toolBarForDelete;
	UIActionSheet *deleateActionSheet;
	UIActionSheet *shareActionSheet;
    UIActivityIndicatorView *activityIndicator;
}

@property(nonatomic,retain) IBOutlet UITableView *imageTable;
@property(nonatomic,retain) IBOutlet  UIActivityIndicatorView *activityIndicator;
@end
