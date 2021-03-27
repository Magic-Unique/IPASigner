//
//  ISSigner.m
//  IPASigner
//
//  Created by 冷秋 on 2019/10/12.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import "ISSigner.h"
#import "ISShellCodesign.h"
#import "ISShellMakeTemp.h"
#import "ISIdentityManager.h"

@interface ISSigner ()

@property (nonatomic, assign) BOOL autoGenEntitlements;

@end

@implementation ISSigner

- (instancetype)initWithIdentify:(ISIdentity *)identity
                       provision:(ISProvision *)provision
                    entitlements:(ISEntitlements *)entitlements {
    self = [super init];
    if (self) {
        _identity = identity;
        _provision = provision;
        _entitlements = entitlements;
        [self __autoInitProperties];
    }
    return self;
}

- (void)__autoInitProperties {
	if (!_identity) {
		ISIdentityManager *mgr = [ISIdentityManager sharedInstance];
		ISIdentity *identity = [mgr signableIdentityForProvision:self.provision];
		_identity = identity;
	}
	
	if (!_entitlements) {
		self.autoGenEntitlements = YES;
		NSDictionary *JSON = self.provision.provision.Entitlements.JSON;
		ISEntitlements *entitlements = [ISEntitlements entitlementsWithEntitlements:JSON];
		_entitlements = entitlements;
	}
}

- (BOOL)signable {
    return _identity && _provision && _entitlements;
}

- (BOOL)sign:(MUPath *)bundle {
	if (bundle.isDirectory) {
		NSString *extension = bundle.pathExtension.lowercaseString;
		if ([extension isEqualToString:@"framework"]) {
			return [self __signLib:bundle];
		}
		else if ([@[@"app", @"appex"] containsObject:extension]) {
			return [self __signApp:bundle];
		}
		return NO;
	}
	else if (bundle.isFile) {
		return [self __signLib:bundle];
	}
	else {
		return NO;
	}
}

- (BOOL)__signApp:(MUPath *)appPath {
	ISEntitlements *entitlements = self.entitlements;
	if (self.autoGenEntitlements) {
		NSDictionary *appEntitlements = ISCodesignDisplayEntitlements(appPath.string);
		NSDictionary *JSON = [self __compineProvisionEntitlements:self.entitlements.entitlements
											  withAppEntitlements:appEntitlements];
		entitlements = [ISEntitlements entitlementsWithEntitlements:JSON];
	}
	if (self.getTaskAllow != ISSignerEntitlementGetTaskAllowDefault) {
		NSMutableDictionary *JSON = [entitlements.entitlements mutableCopy];
		if (self.getTaskAllow == ISSignerEntitlementGetTaskAllowEnable) {
			JSON[@"get-task-allow"] = @YES;
		} else {
			JSON[@"get-task-allow"] = nil;
		}
		entitlements = [ISEntitlements entitlementsWithEntitlements:JSON];
	}
	return ISCodesign(self.identity.SHA1, YES, YES, entitlements.path.string, appPath.string);
}

- (BOOL)__signLib:(MUPath *)libPath {
	return ISCodesign(self.identity.SHA1, YES, YES, nil, libPath.string);
}

- (NSDictionary *)__compineProvisionEntitlements:(NSDictionary *)provisionEntitlements
							 withAppEntitlements:(NSDictionary *)appEntitlements {
	NSMutableDictionary *entitlements = [NSMutableDictionary dictionary];
	[entitlements addEntriesFromDictionary:provisionEntitlements];
	
	NSArray *coverKeys = @[@"com.apple.developer.associated-domains"];
	
	for (NSString *key in coverKeys) {
		if (appEntitlements[key] && provisionEntitlements[key]) {
			entitlements[key] = appEntitlements[key];
		}
	}
	
	return entitlements;
}

@end
