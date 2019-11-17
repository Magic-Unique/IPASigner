//
//  ISProvisionManager.h
//  IPASigner
//
//  Created by 冷秋 on 2019/9/17.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ISProvision.h"

@interface MUPath (Provision)

+ (instancetype)provisionPath;

@end

@interface ISProvisionManager : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong, readonly) NSArray<ISProvision *> *installedProvisions;

@property (nonatomic, strong, readonly) NSDictionary<NSString *, ISProvision *> *nameMap;

@property (nonatomic, strong, readonly) NSDictionary<NSString *, ISProvision *> *bundleIDMap;

@end
