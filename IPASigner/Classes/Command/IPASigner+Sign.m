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

@implementation IPASigner (Sign)

+ (void)__init_sign {
	CLCommand *sign = [[CLCommand mainCommand] defineSubcommand:@"sign"];
	sign.explain = @"Sign IPA with standard mode.";
	
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
			
			MUPath *input = [self inputPathFromProcess:process];
			MUPath *output = [self outputPathFromProcess:process];
			
			NSDictionary *entitlements = ({
				NSMutableDictionary *entitlements = nil;
				if (process.queries[@"entitlements"]) {
					entitlements = [NSMutableDictionary dictionary];
					NSArray *list = process.queries[@"entitlements"];
					for (NSString *item in list) {
						NSArray *components = [item componentsSeparatedByString:@"="];
						if (components.count != 2) {
							CLError(@"Ivalid entitlements value (%@).", item);
							return EXIT_FAILURE;
						}
						entitlements[components.firstObject] = [MUPath pathWithString:components.lastObject];
					}
				}
				[entitlements copy];
			});
			
			ISIPASignerOptions *options = [self genSignOptionsFromProcess:process];
			
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
			options.entitlementsForBundle = ^ISEntitlements *(MUPath *bundle) {
				return entitlements[bundle.CFBundleIdentifier];
			};
			
			if ([ISIPASigner sign:input options:options output:output]) {
				return EXIT_SUCCESS;
			} else {
				return EXIT_FAILURE;
			}
		}];
	}
	
}

@end
