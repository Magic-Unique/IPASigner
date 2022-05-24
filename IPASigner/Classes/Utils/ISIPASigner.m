//
//  ISIPASigner.m
//  IPASigner
//
//  Created by 冷秋 on 2019/10/20.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import "ISIPASigner.h"
#import "MUPath+IPA.h"
#import "ISInfoModifier.h"
#import "ISProvisionManager.h"
#import "ISSigner.h"
#import "ISShellChmod.h"
#import "ISShellLipo.h"
#import <MachOKit/MachOKit.h>
#import <optool/optool.h>

NSString *const ISIPAMainBundleIdentifier = @"com.unique.ipasigner.mainbundleentitlements";

const ISMachOPlatform ISMachOPlatformArmV7 = @"armv7";
const ISMachOPlatform ISMachOPlatformArm64 = @"arm64";

@implementation ISIPASignerOptions

@end

@implementation ISIPASigner

+ (BOOL)sign:(MUPath *)ipaInput
     options:(ISIPASignerOptions *)options
      output:(MUPath *)ipaOutput {
	
	if (!ipaInput.isExist) {
		CLError(@"The file does not exist: %@", ipaInput.string);
		return EXIT_FAILURE;
	}
	
	BOOL isIPA = NO;
	if (ipaInput.isFile && [ipaInput isA:@"ipa"]) {
		isIPA = YES;
	}
	else if (ipaInput.isDirectory && [ipaInput isA:@"app"]) {
		isIPA = NO;
	}
	else {
		CLError(@"Unsupport file type for `%@`", ipaInput.string);
		return NO;
	}
	
	MUPath *tempPath = [[MUPath tempPath] subpathWithComponent:@(NSDate.date.timeIntervalSince1970).stringValue];
	CLInfo(@"Create temp directory: %@", tempPath.string);
	[tempPath createDirectoryWithCleanContents:YES];
	
	if (isIPA) {
		CLInfo(@"Unpackage IPA: %@", ipaInput.string);
		if ([SSZipArchive unzipFileAtPath:ipaInput.string toDestination:tempPath.string] == NO) {
			CLError(@"Can not unzip file.");
			return NO;
		}
	} else {
		CLInfo(@"Copy app: %@", ipaInput.string);
		MUPath *PayloadPath = [tempPath subpathWithComponent:@"Payload"];
		NSError *error = [PayloadPath createDirectoryWithCleanContents:YES];
		if (error) { CLError(@"Can not copy app."); CLError(@"%@", error.localizedDescription); return NO; }
		error = [ipaInput copyInto:PayloadPath autoCover:YES];
		if (error) { CLError(@"Can not copy app."); CLError(@"%@", error.localizedDescription); return NO; }
	}
	
	MUPath *PayloadPath = [tempPath subpathWithComponent:@"Payload"];
	if (!PayloadPath.isDirectory) {
		CLError(@"Can not found Payload directory.");
		return NO;
	}
	
	MUPath *app = [PayloadPath contentsWithFilter:^BOOL(MUPath *content) {
		return content.isDirectory && content.isApp;
	}].firstObject;
	
	if (options.deletePlugIns || options.deleteExtensions) {
		[app.pluginsDirectory remove];
	}
	if (options.deleteWatches || options.deleteExtensions) {
		[app.watchDirectory remove];
		[app.watchPlaceholderDirectory remove];
	}
	
	if (options.CFBundleIdentifier) {
		CLInfo(@"Modify CFBundleIdentifier:");
		CLPushIndent();
		[ISInfoModifier setBundle:app bundleID:options.CFBundleIdentifier];
		CLPopIndent();
	}
	
	if (options.CFBundleVersion) {
		CLInfo(@"Modify CFBundleVersion:");
		CLPushIndent();
		[ISInfoModifier setBundle:app bundleVersion:options.CFBundleVersion];
		CLPopIndent();
	}
	
	if (options.CFBundleShortVersionString) {
		CLInfo(@"Modify CFBundleShortVersionString:");
		CLPushIndent();
		[ISInfoModifier setBundle:app bundleShortVersionString:options.CFBundleShortVersionString];
		CLPopIndent();
	}
	
	if (options.CFBundleDisplayName) {
		CLInfo(@"Modify CFBundleDisplayName:");
		CLPushIndent();
		[ISInfoModifier setBundle:app bundleDisplayName:options.CFBundleDisplayName];
		CLPopIndent();
	}
	
	if (options.enableiTunesFileSharing) {
		[ISInfoModifier setBundle:app iTunesFileSharingEnable:YES];
		app.UIFileSharingEnabled = YES;
	} else if (options.disableiTunesFileSharing) {
		[ISInfoModifier setBundle:app iTunesFileSharingEnable:NO];
	}
	
	if (options.fixIcons) {
		CLInfo(@"Fix icons...");
		[app fixIcons];
	}

	[ISInfoModifier setBundle:app supportAllDevices:YES];
	
	//  分离平台
	if (options.thin) {
		NSString *thin = options.thin;
		
		CLInfo(@"Thin binary to `%@` platform...", thin);
		
		NSMutableArray *embeddedBundles = ({
			NSMutableArray *bundles = [NSMutableArray array];
			[bundles addObjectsFromArray:app.allPlugInApps];
			[bundles addObjectsFromArray:app.allWatchApps];
			[bundles addObject:app];
			[bundles copy];
		});
		
		NSMutableSet *thinedLoadPath = [NSMutableSet set];
		
		void (^ThinBinary)(MUPath *binary) = ^(MUPath *binary) {
			if ([thinedLoadPath containsObject:binary]) { return; }
			[thinedLoadPath addObject:binary];
			CLInfo(@"Thin: %@", [binary relativeStringToPath:PayloadPath]);
			NSArray *platforms = ISLipoArchs(binary.string);
			if ([platforms containsObject:thin] && platforms.count != 1) {
				MUPath *output = [binary pathByReplacingLastPathComponent:@"IPASIGNER_THIN_BINARY"];
				if (ISLipoThin(binary.string, thin, output.string)) {
					[binary remove];
					[output moveTo:binary autoCover:YES];
				}
			}
		};
		
		for (MUPath *appex in embeddedBundles) {
			NSMutableSet *links = [NSMutableSet set];
			[links addObjectsFromArray:appex.CFBundleExecutable.loadedLibraries];
			MUPath *Frameworks = [appex subpathWithComponent:@"Frameworks"];
			if (Frameworks.isDirectory) {
				[Frameworks enumerateContentsUsingBlock:^(MUPath *content, BOOL *stop) {
					[links addObject:content.string];
				}];
			}
			
			[links.allObjects enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL * _Nonnull stop) {
				ThinBinary([MUPath pathWithString:path]);
			}];
			
			ThinBinary(appex.CFBundleExecutable);
		}
	}
	
	//	注入
	if (options.injectDylibs) {
		CLInfo(@"Injection %@", [app relativeStringToPath:PayloadPath]);
		CLPushIndent();
		OPTBinary *binary = [OPTBinary binaryWithPath:app.CFBundleExecutable.string];
		for (MUPath *inject in options.injectDylibs) {
			if (!inject.isExist) {
				CLError(@"The dylib(%@) can not be injected, because the file is not existed.");
				return NO;
			}
			
			if (inject.isDirectory) {
				//	注入 Framework
				MUPath *exec = inject.CFBundleExecutable;
				if (!exec.isFile) {
					CLError(@"The framework(%@) does not contains executable file.", inject.lastPathComponent);
					return NO;
				}
				
				MUPath *Frameworks = [app subpathWithComponent:@"Frameworks"]; [Frameworks createDirectoryWithCleanContents:NO];
				MUPath *target = [Frameworks subpathWithComponent:inject.lastPathComponent];
				if (target.isExist) {
					CLError(@"The framework(%@) can not be injected, because it is areadly existed in app.", target.lastPathComponent);
					return NO;
				}
				
				NSString *installPath = [NSString stringWithFormat:@"@executable_path/Frameworks/%@/%@", target.lastPathComponent, exec.lastPathComponent];
				CLInfo(@"Inject framework: %@", installPath);
				[inject copyTo:target autoCover:YES];
				[binary install:installPath];
			}
			else {
				//	注入 dylib
				MUPath *target = [app subpathWithComponent:inject.lastPathComponent];
				if (target.isExist) {
					CLError(@"The dylib(%@) can not be injected, because it is areadly existed in app.", target.lastPathComponent);
					return NO;
				}
				
				NSString *installPath = [NSString stringWithFormat:@"@executable_path/%@", target.lastPathComponent];
				CLInfo(@"Inject dylib: %@", installPath);
				[inject copyTo:target autoCover:YES];
				[binary install:installPath];
			}
		}
		CLInfo(@"Write new binary...");
		[binary save];
		CLPopIndent();
	}
	
	//	签名
	if (!options.ignoreSign) {
		NSArray *embeddedBundles = ({
			NSMutableArray *bundles = [NSMutableArray array];
			[bundles addObjectsFromArray:app.allPlugInApps];
			[bundles addObjectsFromArray:app.allWatchApps];
			[bundles addObject:app];
			[bundles copy];
		});
		NSMutableSet *signedPath = [NSMutableSet set];
		for (MUPath *appex in embeddedBundles) {
			NSString *CFBundleIdentifier = appex.CFBundleIdentifier;
			
			ISProvision *provision = options.provisionForBundle(appex);
			if (!provision) {
				CLError(@"Can not sign %@ without provision", CFBundleIdentifier);
				return NO;
			}
			
			ISIdentity *identity = ({
				ISIdentity *identity = nil;
				NSArray *identities = ISGetSignableIdentityFromProvision(provision);
				if (identities.count == 0) {
					
				} else if (identities.count == 1) {
					identity = identities.firstObject;
				} else {
					options.identityForProvision(provision, identities);
				}
				identity;
			});
			ISEntitlements *entitlements = options.entitlementsForBundle(appex);
			
			ISSigner *signer = [[ISSigner alloc] initWithIdentify:identity
														provision:provision
													 entitlements:entitlements];
			if ([options.getTaskAllow isEqualToString:@"0"]) {
				signer.getTaskAllow = ISSignerEntitlementGetTaskAllowDisable;
			} else if ([options.getTaskAllow isEqualToString:@"1"]) {
				signer.getTaskAllow = ISSignerEntitlementGetTaskAllowEnable;
			}
			
			CLInfo(@"CodeSign: %@", appex.lastPathComponent);
			CLPushIndent();
			MUPath *from = provision.path;
			MUPath *to = [appex subpathWithComponent:@"embedded.mobileprovision"];
			CLInfo(@"Embedded provision profile: %@", provision.provision.Name);
			[from copyTo:to autoCover:YES];
			
			NSMutableSet *links = [NSMutableSet set];
			[links addObjectsFromArray:appex.CFBundleExecutable.loadedLibraries];
			MUPath *Frameworks = [appex subpathWithComponent:@"Frameworks"];
			if (Frameworks.isDirectory) {
				[Frameworks enumerateContentsUsingBlock:^(MUPath *content, BOOL *stop) {
					[links addObject:content.string];
				}];
			}
			
			[links.allObjects enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL * _Nonnull stop) {
				MUPath *dylib = [MUPath pathWithString:path];
				if ([signedPath containsObject:path]) {
					return;
				}
				CLInfo(@"Sign %@", [dylib relativeStringToPath:PayloadPath]);
				[signer sign:dylib];
				[signedPath addObject:path];
			}];
			
			CLInfo(@"Sign %@", [appex relativeStringToPath:PayloadPath]);
			ISChmod(appex.CFBundleExecutable.string, 777);
			[signer sign:appex];
			CLPopIndent();
		}
	}
	
	// 替换
	if (options.replace) {
		ipaOutput = ipaInput;
	}
	
	// 压缩
	if ([ipaOutput isA:@"app"]) {
		CLInfo(@"Output App: %@", ipaOutput.string);
		[ipaOutput remove];
		NSError *error = [app moveTo:ipaOutput autoCover:YES];
		if (!error) {
			CLSuccess(@"Done!");
			return YES;
		} else {
			CLError(@"Output failed.");
			CLError(@"%@", error.localizedDescription);
			return NO;
		}
	}
	else {
		CLInfo(@"Package IPA: %@", ipaOutput.string);
		
		BOOL result = [SSZipArchive createZipFileAtPath:ipaOutput.string withContentsOfDirectory:tempPath.string];
		if (result) {
			CLSuccess(@"Done!");
			return YES;
		} else {
			CLError(@"Package failed.");
			return NO;
		}
		
	}
	
}

@end
