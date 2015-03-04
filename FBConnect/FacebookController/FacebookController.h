
#import <Foundation/Foundation.h>
#import "FBConnect.h"


@protocol FacebookControllerDelegate <NSObject>
@optional

-(void) facebookDidLoginSuccessfully:(BOOL)successfully;
-(void) facebookDidGetUid:(NSString*)uid successfully:(BOOL)successfully;
-(void) facebookDidGetFiends:(NSArray*)friends successfully:(BOOL)successfully;
-(void) facebookDidPublishSuccessfully:(BOOL)successfully;
-(void) facebookDidCloseErrorAlert;
-(void) facebookDidGetPic:(NSData*)pic successfully:(BOOL)successfully;

@end


@interface FacebookController : NSObject <FBDialogDelegate, FBRequestDelegate, FBSessionDelegate>
{
	Facebook* facebook;
	
	int action;
	NSMutableDictionary* publishStreamParams;
	NSMutableArray* requestStack;
	
	id<FacebookControllerDelegate> delegate;
}

@property (nonatomic, assign) id<FacebookControllerDelegate> delegate;

+(FacebookController*) sharedController;

-(BOOL) isLoggedIn;
-(void) logout;
-(void) login;
-(void) loginAndGetUid;
-(void) getFriendList;
-(void) publishStream:(NSDictionary*)publishParams;
//-(void) publishInvitationsForUsers:(NSArray*)userIds userNames:(NSArray*)userNames joinToLeague:(NSString*)league;
-(void) publishInvitationsForUsers:(NSArray*)userIds linkToShare:(NSArray*)link  userNames:(NSArray*)userNames joinToLeague:(NSString*)league imageUrl:(NSArray *)imageUrl;
-(void) getProfileImage:(NSString*)fbID;

@end

extern NSString* kFbApiKey;
extern NSString* kFbApiSecret;
extern NSString* kFbAppId;
