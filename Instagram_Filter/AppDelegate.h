//
//  AppDelegate.h
//  Instagram_Filter
//
//  Created by Zoo on 09/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    
     UIWindow *window;
    UINavigationController *navController;
 
}
@property (retain, nonatomic)IBOutlet UINavigationController *navController;
@property (retain, nonatomic)IBOutlet UIWindow *window;

@end
