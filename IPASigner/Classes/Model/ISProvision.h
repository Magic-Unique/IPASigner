//
//  ISProvision.h
//  IPASigner
//
//  Created by 冷秋 on 2019/9/17.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ISIdentity.h"

@interface ISProvision : NSObject

@property (nonatomic, strong, readonly) MUPath *path;

@property (nonatomic, strong, readonly) MPProvision *provision;

+ (instancetype)provisionWithPath:(MUPath *)path;

@end

FOUNDATION_EXTERN ISProvision *ISGetNewestProvision(ISProvision *obj1, ISProvision *obj2);

FOUNDATION_EXTERN NSArray<ISIdentity *> *ISGetSignableIdentityFromProvision(ISProvision *provision);
