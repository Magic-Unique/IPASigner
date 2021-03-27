//
//  IPASigner+Sign.m
//  IPASigner
//
//  Created by 冷秋 on 2019/9/24.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import "IPASigner+Sign.h"
#import "NSArray+IPASigner.h"
#import "ISProvisionManager.h"
#import "ISIdentityManager.h"
#import "ISShellMakeTemp.h"
#import "MUPath+IPA.h"
#import "ISSigner.h"
#import "ISInfoModifier.h"
#import "ISIPASigner.h"

static int IPASignInStandardMode(CLProcess *process, MPProvisionType type) {
	
	MUPath *input = [IPASigner inputPathFromProcess:process];
	MUPath *output = [IPASigner outputPathFromProcess:process];
	
	ISIPASignerOptions *options = [IPASigner genSignOptionsFromProcess:process];
	
	CLInfo(@"Reading profile...");
	NSDictionary *map = [[[ISProvisionManager sharedInstance].installedProvisions signer_filte:^BOOL(ISProvision *obj) {
		return obj.provision.type == type;
	}] signer_mapWithKey:^NSString *(ISProvision *obj) {
		return obj.provision.bundleIdentifier;
	} choose:^ISProvision *(ISProvision *obj1, ISProvision *obj2) {
		return ISGetNewestProvision(obj1, obj2);
	}];
	
	CLInfo(@"Reading identities...");
	[[ISIdentityManager sharedInstance] readIdentities];
	
	options.provisionForBundle = ^ISProvision *(MUPath *bundle) {
		return map[bundle.CFBundleIdentifier];
	};
	options.identityForProvision = ^ISIdentity *(ISProvision *provision, NSArray<ISIdentity *> *identities) {
		return identities.firstObject;
	};
	
	if ([ISIPASigner sign:input options:options output:output]) {
		return EXIT_SUCCESS;
	} else {
		return EXIT_FAILURE;
	}
}

@implementation IPASigner (Sign)

+ (void)__init_sign {
	CLCommand *sign = [[CLCommand mainCommand] defineSubcommand:@"sign"];
	sign.explain = @"Sign IPA with standard mode.";
	[self addGeneralArgumentsToCommand:sign];
	
	NSArray<NSString *> *modes = @[@"development", @"ad-hoc", @"app-store", @"in-house"];
	NSArray<NSNumber *> *types = @[@(MPProvisionTypeDevelopment),
								   @(MPProvisionTypeAdHoc),
								   @(MPProvisionTypeAppStore),
								   @(MPProvisionTypeInHouse)];
	
	for (NSUInteger i = 0; i < modes.count; i++) {
		NSString *mode = modes[i];
		MPProvisionType type = types[i].unsignedIntegerValue;
		CLCommand *cmd = [sign defineSubcommand:mode];
		cmd.explain = [NSString stringWithFormat:@"Sign with %@ mode", mode];
		
		[self addGeneralArgumentsToCommand:cmd];
		
		[cmd handleProcess:^int(CLCommand * _Nonnull command, CLProcess * _Nonnull process) {
			return IPASignInStandardMode(process, type);
		}];
		
		sign.setFlag(mode).setExplain(cmd.explain);
	}
	
	[sign handleProcess:^int(CLCommand * _Nonnull command, CLProcess * _Nonnull process) {
		
		NSMutableArray *list = [NSMutableArray array];
		for (NSUInteger i = 0; i < modes.count; i++) {
			NSString *mode = modes[i];
			if ([process flag:mode]) {
				[list addObject:mode];
			}
		}
		if (list.count == 0) {
			CLError(@"You must type in a mode (--developement, --ad-hoc, --app-store, --in-house)");
			return EXIT_FAILURE;
		}
		if (list.count > 1) {
			CLError(@"Too many modes, only require one mode (--developement, --ad-hoc, --app-store, --in-house)");
			return EXIT_FAILURE;
		}
		
		NSString *mode = list.firstObject;
		MPProvisionType type = [@[@"unknow", @"development", @"ad-hoc", @"app-store", @"in-house"] indexOfObject:mode];
		
		return IPASignInStandardMode(process, type);
	}];
}

@end
