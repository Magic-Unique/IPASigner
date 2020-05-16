//
//  IPASigner+Resign.m
//  IPASigner
//
//  Created by 冷秋 on 2019/9/25.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import "IPASigner+Resign.h"
#import "ISProvisionManager.h"
#import "ISIdentityManager.h"

@implementation IPASigner (Resign)

+ (void)__init_resign {
	CLCommand *resign = [[CLCommand mainCommand] defineSubcommand:@"resign"];
	resign.explain = @"Sign IPA with custom mode.";
	
	CLQuery *profile = resign.setQuery(@"profile").setAbbr('p').optional().setExample(@"path|name|uuid|bundleid").setExplain(@"Choose a provision profile.");
	NSString *defaultProfile = [NSUserDefaults standardUserDefaults][IS_CONFIG_KEY_default_profile];
	if (defaultProfile) {
		profile.optional().setDefaultValue(defaultProfile);
	} else {
		profile.require();
	}
	
	[self addGeneralArgumentsToCommand:resign];
	[resign handleProcess:^int(CLCommand * _Nonnull command, CLProcess * _Nonnull process) {
		MUPath *input = [self inputPathFromProcess:process];
		MUPath *output = [self outputPathFromProcess:process];
		
		CLInfo(@"Reading profile...");
		ISProvision *provision = ({
			ISProvision *provision = nil;
			NSString *profile = process.queries[@"profile"];
			do {
				if ([profile.pathExtension.lowercaseString isEqualToString:@"mobileprovision"]) {
					provision = [ISProvision provisionWithPath:[MUPath pathWithString:profile]];
					break;
				}
				if ([[NSUUID alloc] initWithUUIDString:profile]) {
					NSString *fileName = [NSString stringWithFormat:@"%@.mobileprovision", profile];
					MUPath *path = [[MUPath provisionPath] subpathWithComponent:fileName];
					provision = [ISProvision provisionWithPath:path];
					break;
				}
				NSDictionary *map = [ISProvisionManager sharedInstance].nameMap;
				if (map[profile]) {
					provision = map[profile];
					break;
				}
				map = [ISProvisionManager sharedInstance].bundleIDMap;
				if (map[profile]) {
					provision = map[profile];
					break;
				}
			} while (NO);
			if (!provision) {
				CLError(@"Can not found profile: %@", profile);
				return EXIT_FAILURE;
			}
			provision;
		});
		CLInfo(@"Reading profile: %@", provision.provision.Name);
		
		CLInfo(@"Reading identities...");
		[[ISIdentityManager sharedInstance] readIdentities];
		
		ISIPASignerOptions *options = [self genSignOptionsFromProcess:process];
		options.provisionForBundle = ^ISProvision *(MUPath *bundle) {
			return provision;
		};
		options.identityForProvision = ^ISIdentity *(ISProvision *provision, NSArray<ISIdentity *> *identities) {
			return identities.firstObject;
		};
		options.entitlementsForBundle = ^ISEntitlements *(MUPath *bundle) {
			return nil;
		};
		
		BOOL result = [ISIPASigner sign:input options:options output:output];
		if (result) {
			return EXIT_SUCCESS;
		} else {
			return EXIT_FAILURE;
		}
	}];
}

@end
