//
//  ISSigner.h
//  IPASigner
//
//  Created by 冷秋 on 2019/10/12.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUPath+IPA.h"
#import "ISIdentity.h"
#import "ISProvision.h"
#import "ISEntitlements.h"

typedef NS_ENUM(NSUInteger, ISSignerEntitlementGetTaskAllow) {
	ISSignerEntitlementGetTaskAllowDefault,
	ISSignerEntitlementGetTaskAllowEnable,
	ISSignerEntitlementGetTaskAllowDisable,
};

@interface ISSigner : NSObject

@property (nonatomic, copy, readonly) ISIdentity *identity;

@property (nonatomic, copy, readonly) ISProvision *provision;

@property (nonatomic, copy, readonly) ISEntitlements *entitlements;

@property (nonatomic, assign) ISSignerEntitlementGetTaskAllow getTaskAllow;

- (instancetype)initWithIdentify:(ISIdentity *)identity
					   provision:(ISProvision *)provision
					entitlements:(ISEntitlements *)entitlements;

- (BOOL)sign:(MUPath *)bundle;

@end
