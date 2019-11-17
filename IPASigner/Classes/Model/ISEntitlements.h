//
//  ISEntitlements.h
//  IPASigner
//
//  Created by 冷秋 on 2019/10/17.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ISEntitlements : NSObject

@property (nonatomic, strong, readonly) MUPath *path;

@property (nonatomic, strong, readonly) NSDictionary *entitlements;

+ (instancetype)entitlementsWithPath:(MUPath *)path;

+ (instancetype)entitlementsWithEntitlements:(NSDictionary *)entitlements;

@end
