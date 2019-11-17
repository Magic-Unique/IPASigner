//
//  IPASigner+Provision.m
//  IPASigner
//
//  Created by 冷秋 on 2019/9/17.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import "IPASigner+Provision.h"
#import "ISProvisionManager.h"
#import "ISIdentityManager.h"

@implementation IPASigner (Provision)

+ (CLCommand *)__provisionCommand {
	static CLCommand *provision = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		provision = [[CLCommand mainCommand] defineSubcommand:@"provision"];
		provision.explain = @"Lookin for local provision profiles.";
	});
	return provision;
}

+ (void)__init_provision {
	CLCommand *list = [[self __provisionCommand] defineForwardingSubcommand:@"list"];
//	list.setQuery(@"bundle-identifier").setAbbr('b').optional().setExample(@"BUNDLE_ID").setExplain(@"Filt with bundle-identifier");
	list.setQuery(@"type").setAbbr('p').optional().setExample(@"development|ad-hoc|app-store|in-house").setExplain(@"Filt with type");
	list.setQuery(@"name").setAbbr('n').optional().setExample(@"PROFILE_NAME").setExplain(@"Filt with name");
	list.setQuery(@"team-id").setAbbr('t').optional().setExample(@"TEAM_ID").setExplain(@"Filt with team id");
	
	list.setFlag(@"signable").setAbbr('s').setExplain(@"Only display signable provision");
	
	[list handleProcess:^int(CLCommand * _Nonnull command, CLProcess * _Nonnull process) {

		NSString *BUNDLE_IDENTIFIER = process.queries[@"bundle-identifier"];
		MPProvisionType type = ({
			MPProvisionType type = MPProvisionTypeUnknow;
			if (process.queries[@"type"]) {
				NSString *_type = process.queries[@"type"];
				_type = _type.lowercaseString;
				if ([_type isEqualToString:@"development"]) {
					type = MPProvisionTypeDevelopment;
				}
				else if ([_type isEqualToString:@"ad-hoc"]) {
					type = MPProvisionTypeAdHoc;
				}
				else if ([_type isEqualToString:@"app-store"]) {
					type = MPProvisionTypeAppStore;
				}
				else if ([_type isEqualToString:@"in-house"]) {
					type = MPProvisionTypeInHouse;
				}
			}
			type;
		});
		NSString *NAME = process.queries[@"name"];
		NSString *TEAM_ID = process.queries[@"team-id"];
		
		BOOL signable = [process flag:@"signable"];
		
		ISProvisionManager *provisionMgr = [ISProvisionManager sharedInstance];
		
		NSArray<ISProvision *> *provisions = [[provisionMgr.installedProvisions signer_filte:^BOOL(ISProvision *obj) {
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
		}] signer_mapWithKey:^NSString *(ISProvision *obj) {
			return obj.provision.Name;
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
	}];
}

@end
