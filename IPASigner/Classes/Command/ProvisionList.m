//
//  ProvisionList.m
//  IPASigner
//
//  Created by 吴双 on 2026/3/6.
//  Copyright © 2026 Magic-Unique. All rights reserved.
//

#import "ProvisionList.h"
#import <MobileProvision/MobileProvision.h>
#import "ISProvisionManager.h"

CLConvertType(MPProvisionType) {
	NSDictionary *map = @{
		@"development" : @(MPProvisionTypeDevelopment),
		@"ad-hoc" : @(MPProvisionTypeAdHoc),
		@"app-store" : @(MPProvisionTypeAppStore),
		@"in-house" : @(MPProvisionTypeInHouse),
	};
	NSNumber *value = map[string];
	if (value) {
		return value.unsignedIntegerValue;
	}
	return MPProvisionTypeUnknow;
}

@implementation ProvisionList

command_configuration(command) {
	command.name = @"list";
	command.note = @"List out all installed profile";
}

command_option(BOOL, signable, shortName='s', note=@"Only display signable provision")

command_option(CLString, bundleId, shortName='b', nullable, placeholder=@"BUNDLE_ID", note=@"Filt with bundle-identifier");
command_option(MPProvisionType, type, shortName='p', nullable)
command_option(CLString, name, shortName='n', nullable)
command_option(CLString, teamId, shortName='t', nullable)

//	list.setQuery(@"bundle-identifier").setAbbr('b').optional().setExample(@"BUNDLE_ID").setExplain(@"Filt with bundle-identifier");
//	list.setQuery(@"type").setAbbr('p').optional().setExample(@"development|ad-hoc|app-store|in-house").setExplain(@"Filt with type");
//	list.setQuery(@"name").setAbbr('n').optional().setExample(@"PROFILE_NAME").setExplain(@"Filt with name");
//	list.setQuery(@"team-id").setAbbr('t').optional().setExample(@"TEAM_ID").setExplain(@"Filt with team id");

command_main() {
	NSString *BUNDLE_IDENTIFIER = [self bundleId];
	MPProvisionType type = [self type];
	NSString *NAME = [self name];
	NSString *TEAM_ID = [self teamId];
	
	BOOL signable = [self signable];
	
	ISProvisionManager *provisionMgr = [ISProvisionManager sharedInstance];
	
	NSArray<ISProvision *> *provisions = [provisionMgr.installedProvisions signer_mapWithKeyPath:@"provision.Name" filter:^BOOL(ISProvision *obj) {
		if (NAME) {
			if (![obj.provision.Name containsString:NAME]) {
				return NO;
			}
		}
		if (TEAM_ID) {
			if (![obj.provision.TeamIdentifier containsObject:TEAM_ID]) {
				return NO;
			}
		}
		if (BUNDLE_IDENTIFIER) {
			if (![obj.provision.bundleIdentifier isEqualToString:BUNDLE_IDENTIFIER]) {
				return NO;
			}
		}
		if (type) {
			if (obj.provision.type != type) {
				return NO;
			}
		}
		if (signable) {
			NSArray *identites = ISGetSignableIdentityFromProvision(obj);
			if (identites.count == 0) {
				return NO;
			}
		}
		return YES;
	} choose:^ISProvision *(ISProvision *obj1, ISProvision *obj2) {
		return ISGetNewestProvision(obj1, obj2);
	}].allValues;
	
	provisions = [provisions sortedArrayUsingComparator:^NSComparisonResult(ISProvision *obj1, ISProvision *obj2) {
		return [obj1.provision.Name compare:obj2.provision.Name];
	}];
	
	for (ISProvision *provision in provisions) {
		CLANSIPrintf(CCStyleNone, @"%@: %@ (%@)\n", provision.provision.TeamIdentifier.firstObject, provision.provision.Name, provision.provision.bundleIdentifier);
	}
	return EXIT_SUCCESS;
}

@end
