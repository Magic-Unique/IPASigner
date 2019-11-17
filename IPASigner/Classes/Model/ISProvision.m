//
//  ISProvision.m
//  IPASigner
//
//  Created by 冷秋 on 2019/9/17.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import "ISProvision.h"
#import "ISIdentityManager.h"

@implementation ISProvision

+ (instancetype)provisionWithPath:(MUPath *)path {
	ISProvision *provision = [[ISProvision alloc] init];
	provision->_path = path;
	provision->_provision = [MPProvision provisionWithContentsOfFile:path.string];
	return provision;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"Provision %@", self.provision.Name];
}

@end

ISProvision *ISGetNewestProvision(ISProvision *obj1, ISProvision *obj2) {
	if (obj1.provision.CreationDate.timeIntervalSince1970 > obj2.provision.CreationDate.timeIntervalSince1970) {
		return obj1;
	} else {
		return obj2;
	}
}

NSArray<ISIdentity *> *ISGetSignableIdentityFromProvision(ISProvision *provision) {
	NSDictionary<NSString *, ISIdentity *> *registedidentities = [ISIdentityManager sharedInstance].SHA1Map;
	NSMutableArray *identities = [NSMutableArray array];
	[provision.provision.DeveloperCertificates enumerateObjectsUsingBlock:^(MPCertificate * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		NSString *SHA1 = obj.fingerprints.SHA1;
		if (registedidentities[SHA1]) {
			[identities addObject:registedidentities[SHA1]];
		}
	}];
	return [identities copy];
}
