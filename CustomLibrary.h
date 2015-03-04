
//Created by Leonardo Leffa on 04/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomLibrary : NSObject{
    
}
+(BOOL)createDirectory:(NSString *)directoryName;
+(BOOL)saveImageInLibrary:(UIImage*)image imageName:(NSString *)imageName directoryName:(NSString*)directoryName;
+(NSMutableArray*)getImageFromLibrary :(NSString*)directoryName;
+(void)deleteImageFromLibrary:(NSString*)imagePath directoryName:(NSString*)directoryName;
+(void)deleteMultipleImagesFromLibrary:(NSDictionary *)imageDic directoryName:(NSString*)directoryName;
@end
