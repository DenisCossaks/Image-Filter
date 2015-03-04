
//Created by Leonardo Leffa on 04/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomLibrary.h"

@implementation CustomLibrary
+(BOOL)createDirectory:(NSString *)directoryName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:directoryName];
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
        return YES;  
    }else{
        return NO;
    }
}

+(BOOL)saveImageInLibrary:(UIImage*)image imageName:(NSString *)imageName directoryName:(NSString*)directoryName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:directoryName];
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fullPath ;
    if (imageName.length!=0) {
        fullPath = [dataPath stringByAppendingPathComponent:imageName];
    }else{
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
       [formatter setDateFormat:@"YYYYMMddHHmmss"];
        fullPath = [dataPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Image%@.png",[formatter stringFromDate:date]]];
    }
    if (![fileManager fileExistsAtPath:fullPath]) {
           return  [fileManager createFileAtPath:fullPath contents:data attributes:nil];        
    }
    return NO;
}

+(NSMutableArray*)getImageFromLibrary :(NSString*) directoryName{    
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES );
    NSString *dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:directoryName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:dataPath error:NULL];
    //NSString *filePath = [NSString stringWithFormat:@"%@/img%d.png", dataPath];
    NSMutableArray *fullPathArray =[[NSMutableArray alloc] init];
    for (int i=0;i< [contents count]; i++) {
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", dataPath,[contents objectAtIndex:i]];
        [fullPathArray addObject:filePath];
    }
    return fullPathArray;
}


+(void)deleteImageFromLibrary:(NSString *)imagePath directoryName:(NSString*)directoryName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES );
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:directoryName];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:dataPath error:NULL];
    NSMutableArray *fullPathArray =[[NSMutableArray alloc] init];
    for (int i=0;i< [contents count]; i++) {
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", dataPath,[contents objectAtIndex:i]];
        [fullPathArray addObject:filePath];
    }
    for (NSString *path in fullPathArray) {
        //NSString *fullPath = [dataPath stringByAppendingPathComponent:path];
        if ([imagePath isEqualToString:path]) {
            BOOL removeSuccess = [fileManager removeItemAtPath:imagePath error:nil];
            if (removeSuccess) {
                // Error handling
            }else {
                
            }
        }
    }
}

+(void)deleteMultipleImagesFromLibrary:(NSDictionary *)imageDic directoryName:(NSString*)directoryName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES );
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:directoryName];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:dataPath error:NULL];
    NSMutableArray *fullPathArray =[[NSMutableArray alloc] init];
    for (int i=0;i< [contents count]; i++) {
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", dataPath,[contents objectAtIndex:i]];
        [fullPathArray addObject:filePath];
    }
    for (NSString *key in imageDic){
        NSString *imagePath = [imageDic valueForKey:key];
        for (NSString *path in fullPathArray) {
            if ([imagePath isEqualToString:path] &&!([imagePath isEqual:@""])) {
                BOOL removeSuccess = [fileManager removeItemAtPath:imagePath error:nil];
                if (removeSuccess) {
                    // Error handling
                }else {
                    
                }
            }
        }
    }
}

@end