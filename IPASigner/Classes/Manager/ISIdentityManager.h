//
//  ISIdentityManager.h
//  IPASigner
//
//  Created by 冷秋 on 2019/9/17.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ISIdentity.h"
#import "ISProvision.h"

@interface ISIdentityManager : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong, readonly) NSArray<ISIdentity *> *identities;

@property (nonatomic, strong, readonly) NSDictionary<NSString *, ISIdentity *> *SHA1Map;

- (ISIdentity *)signableIdentityForProvision:(ISProvision *)provision;

- (void)readIdentities;

@end
