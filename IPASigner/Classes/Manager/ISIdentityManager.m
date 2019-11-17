//
//  ISIdentityManager.m
//  IPASigner
//
//  Created by 冷秋 on 2019/9/17.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import "ISIdentityManager.h"
#import "ISShellSecurity.h"

@implementation ISIdentityManager

+ (instancetype)sharedInstance {
	static ISIdentityManager *_shared = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_shared = [[self alloc] init];
	});
	return _shared;
}

- (void)readIdentities {
	[self identities];
}

@synthesize identities = _identities;
- (NSArray<ISIdentity *> *)identities {
	if (!_identities) {
		NSArray *list = ISSecurityFindIdentity(ISSecurityCodesigningPolicy, YES);
		NSMutableArray *identities = [NSMutableArray array];
		for (NSDictionary *item in list) {
			NSString *name = item[@"name"];
			NSString *SHA1 = item[@"SHA1"];
			NSNumber *valid = item[@"valid"];
			[identities addObject:[ISIdentity identityWithName:name SHA1:SHA1 valid:valid.boolValue]];
		}
		_identities = [identities copy];
	}
	return _identities;
}

@synthesize SHA1Map = _SHA1Map;
- (NSDictionary<NSString *,ISIdentity *> *)SHA1Map {
	if (!_SHA1Map) {
		NSMutableDictionary *map = [NSMutableDictionary dictionary];
		[self.identities enumerateObjectsUsingBlock:^(ISIdentity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			map[obj.SHA1] = obj;
		}];
		_SHA1Map = [map copy];
	}
	return _SHA1Map;
}

- (ISIdentity *)signableIdentityForProvision:(ISProvision *)provision {
	NSArray<MPCertificate *> *certificates = provision.provision.DeveloperCertificates;
	for (ISIdentity *item in self.identities) {
		for (MPCertificate *certificate in certificates) {
			if ([certificate.fingerprints.SHA1.lowercaseString isEqualToString:item.SHA1.lowercaseString]) {
				return item;
			}
		}
	}
	return nil;
}

@end
