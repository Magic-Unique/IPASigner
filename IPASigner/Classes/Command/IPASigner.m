//
//  IPASigner.m
//  IPASigner
//
//  Created by 冷秋 on 2019/9/17.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import "IPASigner.h"
#import "ISProvisionManager.h"
#import "ISIdentityManager.h"
#import "ISIPASigner.h"
#import "MUPath+IPA.h"
#import "Provision.h"

CLConvertType(ISMachOPlatform) {
	if ([string isEqualToString:@"armv7"]) {
		return ISMachOPlatformArmV7;
	}
	if ([string isEqualToString:@"arm64"]) {
		return ISMachOPlatformArm64;
	}
	*error = IPA_ERROR(-1, @"Unsupport arch type `%@`", string);
	return nil;
}

@implementation IPASigner

command_configuration(command) {
	command.note = @"SIGN/EDIT an ipa/app.";
	command.version = @IPA_VERSION;
	command.subcommands = @[[Provision class]];
}

command_option(CLString, sign, shortName='s', nullable, showInUsage, placeholder=@"PROFILE", note=[self signNote])
+ (NSString *)signNote {
	NSMutableArray *list = [NSMutableArray array];
	[list addObject:@"Provision profile to sign or nil to edit-only."];
	[list addObject:[NSString stringWithFormat:@"%@: Special profile to sign app and ext.", @"NAME/UUID/BUNDLE_ID/FILE_PATH".ansi.bold.ansiText]];
	[list addObject:[NSString stringWithFormat:@"%@/%@/%@/%@: Sign with match bundle-id profile.",
					 @"app-store".ansi.bold.ansiText,
					 @"in-house".ansi.bold.ansiText,
					 @"ad-hoc".ansi.bold.ansiText,
					 @"development".ansi.bold.ansiText
					]];
	[list addObject:[NSString stringWithFormat:@"%@: sign with default profile. (env: IPASIGNER_DEFAULT_PROFILE)", @"-".ansi.bold.ansiText]];
	return [list componentsJoinedByString:@"\n"];
}

command_option(CLString, bundleId, shortName='i', nullable, placeholder=@"com.xxx.xxx", note=@"Modify CFBundleIdentifier")
command_option(CLString, bundleVersion, nullable, placeholder=@"1.0.0", note=@"Modify CFBundleVersion")
command_option(CLString, buildVersion, nullable, placeholder=@"1000", note=@"Modify CFBundleShortVersionString")
command_option(CLString, bundleDisplayName,nullable, placeholder=@"NAME", note=@"Modify CFBundleDisplayName")
command_option(CLString, bundleIcon, nullable, placeholder=@"/path/to/AppIcon.png", note=@"Modify app icon")
command_option(BOOL, supportAllDevices, shortName='a', note=@"Remove Info's value for keyed UISupportDevices.")
command_option(BOOL, fileSharing, note=@"Enable iTunes file sharing")
command_option(BOOL, noFileSharing, note=@"Disable iTunes file sharing")
command_option(BOOL, filePlace, note=@"Enable opening documents in place")
command_option(BOOL, noFilePlace, note=@"Disable opening documents in place")
command_option(BOOL, fixIcons, note=@"Fix icons-losing on high devices.")

command_option(ISMachOPlatform, thin, nullable, placeholder=@"armv7|arm64", note=@"Thin binary")
command_options(CLPath, inject, shortName='I', nullable, placeholder=@"/path/to/dylib", note=@"Inject dylib(s) into binary.")

//	command.setFlag(@"rm-plugins").setExplain(@"Delete all app extensions.");
//	command.setFlag(@"rm-watches").setExplain(@"Delete all watch apps.");
command_option(BOOL, removeExtensions, shortName='r', note=@"Delete all watch apps and plugins.");

command_option(BOOL, replace, shortName='R', note=@"Sign and replace input file.", showInUsage)

//	command.setQuery(@"entitlements").setAbbr('e').optional().setMultiType(CLQueryMultiTypeMoreKeyValue).setExplain(@"Sign with entitlements, bundle_id=entitlement_path");
command_option(CLString, getTaskAllow, shortName='D', nullable, placeholder=@"1|0", note=@"Modify `get-task-allow` in entitlements.")

command_argument(CLPath, input, placeholder=@"/path/to/input.ipa", note=@"Input ipa path.")
command_argument(CLPath, output, nullable, placeholder=@"/path/to/output.ipa", note=@"Output ipa path.")

command_enviroment(CLString, defaultProfile, name=@"IPASIGNER_DEFAULT_PROFILE", note=@"Default profile arguments, sign with `-s -`")
command_enviroment(BOOL, autoRemoveSupportDevices, name=@"IPASIGNER_SUPPORT_ALL_DEVICES", note=@"Remove `UISupportDevices` key by default.")
command_enviroment(BOOL, autoEnableFileSharing, name=@"IPASIGNER_ENABLE_FILE_SHARING", note=@"Enable iTunes file sharing by default.")
command_enviroment(BOOL, autoRemoveExtension, name=@"IPASIGNER_REMOVE_EXTENSIONS", note=@"Remove all extensions by default.")

- (ISIPASignerOptions *)genSignOptions {
	ISIPASignerOptions *options = [ISIPASignerOptions new];
	options.CFBundleIdentifier = [self bundleId];
	options.CFBundleVersion = [self bundleVersion];
	options.CFBundleDisplayName = [self bundleDisplayName];
	options.CFBundleShortVersionString = [self buildVersion];
	options.bundleIconPath = [self bundleIcon];
//	options.deletePlugIns = [process flag:@"rm-plugins"];
//	options.deleteWatches = [process flag:@"rm-watches"];
	options.deleteExtensions = [self removeExtensions] || [self autoRemoveExtension];
	options.supportAllDevices = [self supportAllDevices] || [self autoRemoveSupportDevices];
	options.fixIcons = [self fixIcons];
	options.getTaskAllow = [self getTaskAllow];
	options.replace = [self replace];

	// Thin Binary
	ISMachOPlatform thin = [self thin];
	if (thin && [@[ISMachOPlatformArmV7, ISMachOPlatformArm64] containsObject:thin]) {
		options.thin = thin;
	}
	
	// Injection
	options.injectDylibs = [self inject];
	
	if ([self fileSharing] && [self noFileSharing]) {
		CLError(@"You must type in one of --file-sharing and --no-file-sharing, or without anyone.");
		exit(EXIT_FAILURE);
	}
	else if ([self noFileSharing]) {
		options.disableiTunesFileSharing = YES;
	}
	else if ([self fileSharing] || [self autoEnableFileSharing]) {
		options.enableiTunesFileSharing = YES;
	}

	if ([self filePlace] && [self noFilePlace]) {
		CLError(@"You must type in one of --file-place and --no-file-place, or without anyone.");
		exit(EXIT_FAILURE);
	}
	else if ([self noFilePlace]) {
		options.disableSupportsOpeningDocumentsInPlace = YES;
	}
	else if ([self filePlace]) {
		options.enableSupportsOpeningDocumentsInPlace = YES;
	}

	NSDictionary *entitlements = ({
		NSMutableDictionary *entitlements = nil;
//		if (process.queries[@"entitlements"]) {
//			entitlements = [NSMutableDictionary dictionary];
//			NSArray *list = process.queries[@"entitlements"];
//			for (NSString *item in list) {
//				NSArray *components = [item componentsSeparatedByString:@"="];
//				if (components.count != 2) {
//					entitlements[ISIPAMainBundleIdentifier] = [MUPath pathWithString:components.lastObject];
//				} else {
//					entitlements[components.firstObject] = [MUPath pathWithString:components.lastObject];
//				}
//			}
//		}
		[entitlements copy];
	});
	options.entitlementsForBundle = ^ISEntitlements *(MUPath *bundle) {
		MUPath *_entitlements = entitlements[bundle.CFBundleIdentifier];
		if (!_entitlements && bundle.isApp) {
			_entitlements = entitlements[ISIPAMainBundleIdentifier];
		}
		if (_entitlements) {
			return [ISEntitlements entitlementsWithPath:_entitlements];
		}
		return nil;
	};

	return options;
}

- (MUPath *)inputPath {
	return [self input];
}

- (MUPath *)outputPath {
	if ([self output]) {
		return [self output];
	}
	MUPath *input = [self input];
	return [input pathByReplacingPathExtension:@"signed.ipa"];
}

command_main() {
	MUPath *input = [self inputPath];
	MUPath *output = [self outputPath];

	ISIPASignerOptions *options = [self genSignOptions];
	
	BOOL needsSign = (sign != nil);
	MPProvisionType type = MPProvisionTypeUnknow;
	ISProvision *provision = nil;
	
	if (sign) {
		if ([sign isEqualToString:@"development"]) {
			type = MPProvisionTypeDevelopment;
		}
		else if ([sign isEqualToString:@"ad-hoc"]) {
			type = MPProvisionTypeAdHoc;
		}
		else if ([sign isEqualToString:@"app-store"]) {
			type = MPProvisionTypeAppStore;
		}
		else if ([sign isEqualToString:@"in-house"]) {
			type = MPProvisionTypeInHouse;
		}
		else {
			NSString *profile = sign;
			if ([profile isEqualToString:@"-"]) {
				profile = [self defaultProfile];
				if (!profile) {
					CLError(@"Can not find default profile, Special it with `export IPASIGNER_DEFAULT_PROFILE=XXXX`");
					return EXIT_FAILURE;
				}
			}
			
			CLInfo(@"Reading profile...");
			provision = ({
				ISProvision *provision = nil;
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
		}
	}
	
	if (!needsSign) {
		CLInfo(@"EDIT MODE.")
  		options.provisionForBundle = nil;
  		options.identityForProvision = nil;
  		options.ignoreSign = YES;
	}
	else if (type != MPProvisionTypeUnknow) {
		CLInfo(@"STANDARD MODE.")
		
		CLInfo(@"Reading profile...");
		NSDictionary *map = [[ISProvisionManager sharedInstance].installedProvisions signer_mapWithKeyPath:@"provision.bundleIdentifier" filter:^BOOL(ISProvision *obj) {
			return obj.provision.type == type;
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
		
		
	} else {
		CLInfo(@"CUSTOM MODE.")
		
		CLInfo(@"Reading identities...");
		[[ISIdentityManager sharedInstance] readIdentities];
		
		
		options.provisionForBundle = ^ISProvision *(MUPath *bundle) {
			return provision;
		};
		options.identityForProvision = ^ISIdentity *(ISProvision *provision, NSArray<ISIdentity *> *identities) {
			return identities.firstObject;
		};
	}
	
	
	BOOL result = [ISIPASigner sign:input options:options output:output];
	if (result) {
		return EXIT_SUCCESS;
	} else {
		return EXIT_FAILURE;
	}
}

@end
