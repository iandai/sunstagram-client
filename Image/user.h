//
//  user.h
//  Image
//
//  Created by Ian on 2012/12/17.
//  Copyright (c) 2012年 com.yumemi.ian. All rights reserved.
//

#import <Foundation/Foundation.h>

#define	kUserLoginKey     @"login"
#define kUserPasswordKey  @"password"

@interface user : NSObject {
    NSString *login;
    NSString *password;
    NSURL *siteURL;
}

@property (nonatomic, copy)   NSString *login;
@property (nonatomic, copy)   NSString *password;
@property (nonatomic, retain) NSURL *siteURL;

+ (user *)currentUserForSite:(NSURL *)siteURL;

- (BOOL)hasCredentials;
- (BOOL)authenticate:(NSError **)error;
- (void)saveCredentialsToKeychain;
- (void)addObserver:(id)observer;
- (void)removeObserver:(id)observer;


@end
