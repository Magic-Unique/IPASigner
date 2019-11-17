//
//  ISIdentity.h
//  IPASigner
//
//  Created by 冷秋 on 2019/9/17.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ISIdentity : NSObject

@property (nonatomic, strong, readonly) NSString *SHA1;

@property (nonatomic, strong, readonly) NSString *name;

@property (nonatomic, assign, readonly) BOOL valid;

+ (instancetype)identityWithName:(NSString *)name SHA1:(NSString *)SHA1 valid:(BOOL)valid;

@end
