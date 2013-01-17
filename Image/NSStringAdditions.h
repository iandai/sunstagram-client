//
//  NSStringAdditions.h
//  
//
//  Created by Ian on 2012/12/26.
//
//

#import <Foundation/Foundation.h>
#import <Foundation/NSString.h>

@interface NSString (NSStringAdditions)

+ (NSString *) base64StringFromData:(NSData *)data length:(int)length;

@end
