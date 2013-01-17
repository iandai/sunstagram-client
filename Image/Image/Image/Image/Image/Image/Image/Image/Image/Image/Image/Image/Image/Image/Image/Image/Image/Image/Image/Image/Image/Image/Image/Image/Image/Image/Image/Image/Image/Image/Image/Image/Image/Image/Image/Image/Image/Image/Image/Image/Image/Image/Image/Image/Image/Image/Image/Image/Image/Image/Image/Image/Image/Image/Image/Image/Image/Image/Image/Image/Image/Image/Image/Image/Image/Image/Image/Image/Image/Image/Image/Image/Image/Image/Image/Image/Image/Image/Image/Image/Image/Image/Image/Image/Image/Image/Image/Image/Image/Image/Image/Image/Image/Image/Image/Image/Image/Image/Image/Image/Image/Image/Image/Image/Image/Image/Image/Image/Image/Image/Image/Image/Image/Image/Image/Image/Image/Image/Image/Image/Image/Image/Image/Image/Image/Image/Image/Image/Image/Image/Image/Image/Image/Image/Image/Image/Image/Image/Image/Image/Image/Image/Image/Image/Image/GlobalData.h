//
//  GlobalData.h
//  Image
//
//  Created by Ian on 2012/12/27.
//  Copyright (c) 2012年 com.yumemi.ian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobalData : NSObject

@property(nonatomic) NSString *HostName;
+(NSString *)getHostName;

@end
