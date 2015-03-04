
#import "FacebookController.h"


NSString* kFbApiKey =@"207019949418666"; 
NSString* kFbApiSecret = @"b21b45c91b6c7de515dcfe205a6df9c9";
NSString* kFbAppId = @"207019949418666";

static NSString* fbLoginServerPath = @"http://login.facebook.com";

typedef enum eFacebookActionType
{
	FAT_NO_ACTION,
	FAT_LOGIN,
	FAT_GET_UID,
    FAT_GET_PIC,
	FAT_PUBLISH_STREAM,
	FAT_GET_FRIENDS,
	FAT_PUBLISH_STREAMS_FOR_USERS,
}FacebookActionType;


@interface FacebookController ()
@property (nonatomic, retain) NSMutableDictionary* publishStreamParams;
@property (nonatomic, retain) NSMutableArray* requestStack;
-(BOOL) publishNextUserStream;
@end

@implementation FacebookController
@synthesize delegate;
@synthesize publishStreamParams;
@synthesize requestStack;

static FacebookController* sharedInstance = nil;

+(FacebookController*) sharedController
{
	if(sharedInstance==nil)
	{
		sharedInstance = [[FacebookController alloc] init];
	}
	return sharedInstance;
}

-(id) init
{
	if(self=[super init])
	{
		action = FAT_NO_ACTION;
	}
	return self;
}

-(void) dealloc
{
	self.publishStreamParams = nil;
	self.requestStack = nil;
	[facebook release];
	[super dealloc];
}

-(BOOL) isLoggedIn
{
	return [facebook isSessionValid];
}


-(void)performRequestFromStack
{
	if([requestStack count]>0)
	{
		NSDictionary* requestDict = [requestStack objectAtIndex:0];
		NSLog(@"performRequestFromStack \n%@",requestDict);

		[[requestDict retain] autorelease];
		[requestStack removeObjectAtIndex:0];
		
		[facebook requestWithGraphPath:[requestDict objectForKey:@"graph"]
							 andParams:[requestDict objectForKey:@"params"]
						 andHttpMethod:[requestDict objectForKey:@"method"]
						   andDelegate:self];	
	}
}

-(void) requestLogin
{
	NSArray* permissions = [NSArray arrayWithObjects:@"email",@"user_birthday", @"publish_stream", @"offline_access",nil];
	[facebook authorize:kFbAppId permissions:permissions delegate:self];
}

-(void) requestUid
{
	[facebook requestWithGraphPath:@"me" andDelegate:self];
}

-(void) requestFriendList
{
	NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									@"SELECT uid, name, pic_square, is_app_user FROM user "
									"WHERE uid IN (SELECT uid2 FROM friend WHERE uid1 = me()) ORDER BY name", @"query", nil];
	[facebook requestWithMethodName:@"fql.query" andParams:params andHttpMethod:@"POST" andDelegate:self];
}

-(void) requestPublishStream
{
	[facebook requestWithGraphPath:@"me/photos" andParams:publishStreamParams andHttpMethod:@"POST" andDelegate:self];	
}                                                              /////100000300160902 me/feed

-(void) logout
{
	NSLog(@"FacebookController logout");
	
	NSURL* fbLoginUrl = [NSURL URLWithString:fbLoginServerPath];
	
	NSHTTPCookieStorage* cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	NSArray* cookies = [cookieStorage cookiesForURL:fbLoginUrl];
	for (NSHTTPCookie* cookie in cookies) 
	{
		[cookieStorage deleteCookie:cookie];
	}
    
	if(facebook!=nil)
	{		
		[facebook release];
		facebook = nil;
	}
}


-(void) login //That Method is uses to autherication...
{
	NSLog(@"FacebookController login");
	
	if(facebook==nil)
	{		
		facebook = [[Facebook alloc] init];
	
		if( ![facebook isSessionValid] )
		{
			action = (action==FAT_NO_ACTION ? FAT_LOGIN : action);

			[self requestLogin];
		}
		else
		{
			if( [delegate respondsToSelector:@selector(facebookDidLoginSuccessfully:)] )
			{
				[delegate facebookDidLoginSuccessfully:YES];
			}
		}
	}
}

-(void) loginAndGetUid
{
	NSLog(@"FacebookController loginAndGetUid");
	//NSAssert(action==FAT_NO_ACTION, @"FacebookController request is already in progress");
	action = FAT_GET_UID;
	
	[self login];
	
	if( [self isLoggedIn] )
	{
		[self requestUid];
		//[[RootViewController sharedController] presentLoadingAlert];
	}
}

- (void) getProfileImage:(NSString*)fbID{
    NSLog(@"FacebookController get profile photo");
	//NSAssert(action==FAT_NO_ACTION, @"FacebookController request is already in progress");
	action = FAT_GET_PIC;
    NSString *get_string = [NSString stringWithFormat:@"%@/picture", fbID];
    [facebook requestWithGraphPath:get_string andDelegate:self];
}

-(void) getFriendList
{
	NSLog(@"FacebookController getFriendList");
	//NSAssert(action==FAT_NO_ACTION, @"FacebookController request is already in progress");
	action = FAT_GET_FRIENDS;
	
	[self login];
	
	if( [self isLoggedIn] )
	{
		[self requestFriendList];
		//[[RootViewController sharedController] presentLoadingAlert];
	}
}

-(void) publishStream:(NSDictionary*)publishParams
{
	NSLog(@"FacebookController publishStream");
	//NSAssert(action==FAT_NO_ACTION, @"FacebookController request is already in progress");
	action = FAT_PUBLISH_STREAM;

	self.publishStreamParams = [NSMutableDictionary dictionaryWithDictionary:publishParams];
	
	[self login];
	
	if( [self isLoggedIn] )
	{
		[self requestPublishStream];
		//[[RootViewController sharedController] presentLoadingAlert];
	}
}

-(void) publishStreamsForUsers:(NSDictionary*)publishParamsForUsers
{
	NSLog(@"FacebookController publishStreamsForUsers");
	//NSAssert(action==FAT_NO_ACTION, @"FacebookController request is already in progress");
	action = FAT_PUBLISH_STREAMS_FOR_USERS;
	
	self.requestStack = [NSMutableArray arrayWithCapacity:[publishParamsForUsers count]];
    NSLog(@"publishParamsForUsers=%@",publishParamsForUsers);
	for(NSString* user in publishParamsForUsers)
	{
		NSDictionary* requestParams = [NSDictionary dictionaryWithObjectsAndKeys:
									   [NSString stringWithFormat:@"%@/feed", user], @"graph",
									   [publishParamsForUsers objectForKey:user], @"params",
									   @"POST", @"method", nil];
		[requestStack addObject:requestParams];
        NSLog(@"request for parm=%@",requestParams);
	}
	
	[self login];
	
	if( [self isLoggedIn] )
	{
		[self publishNextUserStream];
		//[[RootViewController sharedController] presentLoadingAlert];
	}
}

-(BOOL) publishNextUserStream
{
	BOOL progress = NO;
	if([requestStack count]>0)
	{
		[self performRequestFromStack];
		progress = YES;
	}
	else
	{
		self.requestStack = nil;
		
		if( [delegate respondsToSelector:@selector(facebookDidPublishSuccessfully:)] )
		{
			[delegate facebookDidPublishSuccessfully:YES];
		}
	}	
	return progress;
}

- (void)fbDidNotLogin:(BOOL)cancelled
{
	NSLog(@"FacebookController fbDidNotLogin");

	self.publishStreamParams = nil;
	self.requestStack = nil;
	[facebook release];
	facebook = nil; 

    if (cancelled) {
     //   LoginForm *object = [[LoginForm alloc] init];
    }
	if(!cancelled)
	{
//		[[RootViewController sharedController] presentModalAlertWithTitle:@"Sorry" 
//																  message:@"Facebook login failed" 
//																   target:self
//																 selector:@selector(errorAlertDidClose)
//															 buttonTitles:@"OK", nil];
	}
	
	FacebookActionType fat = action;
	action = FAT_NO_ACTION;
		
	if( [delegate respondsToSelector:@selector(facebookDidLoginSuccessfully:)] )
	{
		[delegate facebookDidLoginSuccessfully:NO];
	}
	
	if(fat==FAT_GET_UID)
	{
		if( [delegate respondsToSelector:@selector(facebookDidGetUid:successfully:)] )
		{
			[delegate facebookDidGetUid:nil successfully:NO];
		}
	}
	else if (fat == FAT_GET_FRIENDS)
	{
		if( [delegate respondsToSelector:@selector(facebookDidGetFiends:successfully:)] )
		{
			[delegate facebookDidGetFiends:nil successfully:NO];
		}
	}
	else if(fat==FAT_PUBLISH_STREAM || fat==FAT_PUBLISH_STREAMS_FOR_USERS)
	{
		if( [delegate respondsToSelector:@selector(facebookDidPublishSuccessfully:)] )
		{
			[delegate facebookDidPublishSuccessfully:NO];
		}
	}else if(fat==FAT_GET_PIC){
        if( [delegate respondsToSelector:@selector(facebookDidGetPic:successfully:)] )
		{
			[delegate facebookDidGetPic:nil successfully:NO];
		}
    }
	
}

-(void) fbDidLogin 
{
	NSLog(@"FacebookController fbDidLogin");
	
	if(action == FAT_LOGIN)
	{
		action = FAT_NO_ACTION;
		
		if( [delegate respondsToSelector:@selector(facebookDidLoginSuccessfully:)] )
		{
			[delegate facebookDidLoginSuccessfully:YES];
		}
	}
	else if (action == FAT_GET_UID)
	{
		[self requestUid];
		//[[RootViewController sharedController] presentLoadingAlert];
	}
	else if (action == FAT_GET_FRIENDS)
	{
		[self requestFriendList];
		//[[RootViewController sharedController] presentLoadingAlert];
	}
	else if (action == FAT_PUBLISH_STREAM)
	{
		[self requestPublishStream];
		//[[RootViewController sharedController] presentLoadingAlert];
	}	
	else if (action == FAT_PUBLISH_STREAMS_FOR_USERS)
	{
		BOOL progress = [self publishNextUserStream];
		if(progress)
		{
			//[[RootViewController sharedController] presentLoadingAlert];
		}
	}
	NSString *accessToken= facebook.accessToken;
    NSLog(@"accessToken FB=%@",accessToken);
    //--nsuserdefaults----
    NSUserDefaults *defaultUserDataFb= [[NSUserDefaults alloc] init];
    [defaultUserDataFb setValue:accessToken forKey:@"accessToken"];

}

- (void)request:(FBRequest*)request didFailWithError:(NSError*)error 
{
	NSLog(@"FacebookController request:didFailWithError: %@",[error localizedDescription]);
//	[[RootViewController sharedController] presentModalAlertWithTitle:@"Sorry" 
//															  message:@"Facebook connection failed. Check your facebook settings." 
//															   target:self
//															 selector:@selector(errorAlertDidClose)
//														 buttonTitles:@"OK", nil];
	FacebookActionType fat = action;
	action = FAT_NO_ACTION;
	
	if(fat==FAT_GET_UID)
	{
		if( [delegate respondsToSelector:@selector(facebookDidGetUid:successfully:)] )
		{
			[delegate facebookDidGetUid:nil successfully:NO];
		}
	}
	else if (fat == FAT_GET_FRIENDS)
	{
		if( [delegate respondsToSelector:@selector(facebookDidGetFiends:successfully:)] )
		{
			[delegate facebookDidGetFiends:nil successfully:NO];
		}
	}
	else if(fat==FAT_PUBLISH_STREAM)
	{
		self.publishStreamParams = nil;
		
		if( [delegate respondsToSelector:@selector(facebookDidPublishSuccessfully:)] )
		{
			[delegate facebookDidPublishSuccessfully:NO];
		}
	}
	else if(fat==FAT_PUBLISH_STREAMS_FOR_USERS)
	{
		
		/*self.requestStack = nil;
		
		if( [delegate respondsToSelector:@selector(facebookDidPublishSuccessfully:)] )
		{
			[delegate facebookDidPublishSuccessfully:NO];
		}
         
     	action = FAT_NO_ACTION;
         */
		
		BOOL progress = [self publishNextUserStream];
		if(!progress)
		{
			//[[RootViewController sharedController] dismissModalAlert];
			action = FAT_NO_ACTION;
		}
	}else if(fat==FAT_GET_PIC){
        if( [delegate respondsToSelector:@selector(facebookDidGetPic:successfully:)] )
		{
			[delegate facebookDidGetPic:nil successfully:NO];
		}
    }
	
}

BOOL forFirst=YES;
- (void)request:(FBRequest*)request didLoad:(id)result
{
	NSLog(@"FacebookController request:didLoad: %@", result);
    NSString *birthDate;
    if(forFirst)
    {
	birthDate=(NSString*) [result objectForKey:@"birthday"];
        if(birthDate.length>0)//added By Gagan...
        {
            NSUserDefaults *userDefaults=[NSUserDefaults  standardUserDefaults];
            [userDefaults setObject:birthDate forKey:@"fbBirthDate"];
        }
        forFirst=NO;
    }
 	if(action==FAT_GET_UID)
	{
		id uid = [result objectForKey:@"id"];
        [[NSUserDefaults  standardUserDefaults] setObject:[result objectForKey:@"id"] forKey:@"FBuid"];
		action = FAT_NO_ACTION;
		
		if( [delegate respondsToSelector:@selector(facebookDidGetUid:successfully:)] )
		{
			[delegate facebookDidGetUid:uid successfully:YES];
		}
	}
	else if (action == FAT_GET_FRIENDS)
	{
		//[[RootViewController sharedController] dismissModalAlert];
		action = FAT_NO_ACTION;
		
		if( [delegate respondsToSelector:@selector(facebookDidGetFiends:successfully:)] )
		{
			[delegate facebookDidGetFiends:result successfully:YES];
		}
	}
	else if(action==FAT_PUBLISH_STREAM)
	{
		//[[RootViewController sharedController] dismissModalAlert];
		action = FAT_NO_ACTION;
		self.publishStreamParams = nil;
		
		if( [delegate respondsToSelector:@selector(facebookDidPublishSuccessfully:)] )  // Comment to remove crash from Share
		{
			[delegate facebookDidPublishSuccessfully:YES];
		}
		
	}
	else if(action==FAT_PUBLISH_STREAMS_FOR_USERS)
	{
		BOOL progress = [self publishNextUserStream];
		if(!progress)
		{
			//[[RootViewController sharedController] dismissModalAlert];
			action = FAT_NO_ACTION;
		}
	}else if(action==FAT_GET_PIC){
        if( [delegate respondsToSelector:@selector(facebookDidGetPic:successfully:)] )
		{
			[delegate facebookDidGetPic:result successfully:YES];
		}
    }
}

-(void) errorAlertDidClose
{
	if( [delegate respondsToSelector:@selector(facebookDidCloseErrorAlert)] )
	{
		[delegate facebookDidCloseErrorAlert];
	}
}

#pragma mark -
#pragma mark publishing invitations

-(void) publishInvitationsForUsers:(NSArray*)userIds linkToShare:(NSArray*)link  userNames:(NSArray*)userNames joinToLeague:(NSString*)league imageUrl:(NSArray *)imageUrl
{
	//HFHAppDelegate* app = (HFHAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSMutableDictionary* userStreams = [NSMutableDictionary dictionaryWithCapacity:[userIds count]];
	
	
	int count=0;
	for(NSString* userId in userIds)
	{
		NSMutableDictionary* params = [NSMutableDictionary dictionary];
		
		// Message
		//NSString* message = [NSString stringWithFormat:@"has invited you to join the %@ in wishlu", league];
		NSString* message =@"wishlu invitation";
        NSLog(@"FB wall post: %@", message);

	
		[params setObject:message forKey:@"message"];
		
		// Link params
		[params setObject:[link objectAtIndex:count] forKey:@"link"];
		[params setObject:@"invitation" forKey:@"name"];
		[params setObject:@"Zoo.Zoo.net" forKey:@"caption"];
		[params setObject:@"invitation" forKey:@"description"];
		// Link params
        if ([imageUrl count] != 0) {
            NSLog(@"imageUrl objectAtIndex: %d: URL : %@",count, [imageUrl objectAtIndex:count]);
            [params setObject:[imageUrl objectAtIndex:count] forKey:@"picture"];
        }else
		    [params setObject:@"" forKey:@"picture"];
        
		count ++;
		// Actions links
		NSString* links = [NSString stringWithFormat:@"{\"name\":\"App Store page\", \"link\": \"http://www/wishluapp.com\"}"];
        
        
		[params setObject:links forKey:@"actions"];

		[userStreams setObject:params forKey:userId];
	}

	[self publishStreamsForUsers:userStreams];
}



@end
