//
//  IPASigner.m
//  IPASigner
//
//  Created by 冷秋 on 2019/9/17.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import "IPASigner.h"
#import "MUPath+IPA.h"

@implementation IPASigner

+ (void)addGeneralArgumentsToCommand:(CLCommand *)command {
	command.setQuery(@"bundle-id").setAbbr('i').optional().setExample(@"com.xxx.xxx").setExplain(@"Modify CFBundleIdentifier");
	command.setQuery(@"bundle-version").optional().setExample(@"1.0.0").setExplain(@"Modify CFBundleVersion");
	command.setQuery(@"build-version").optional().setExample(@"1000").setExplain(@"Modify CFBundleShortVersionString");
	command.setQuery(@"bundle-display-name").optional().setExample(@"NAME").setExplain(@"Modify CFBundleDisplayName");
	command.setFlag(@"support-all-devices").setAbbr('a').setExplain(@"Remove Info's value for keyed UISupportDevices.");
	command.setFlag(@"file-sharing").setExplain(@"Enable iTunes file sharing");
	command.setFlag(@"no-file-sharing").setExplain(@"Disable iTunes file sharing");
	command.setFlag(@"file-place").setExplain(@"Enable opening documents in place");
	command.setFlag(@"no-file-place").setExplain(@"Disable opening documents in place");
	command.setFlag(@"fix-icons").setExplain(@"Fix icons-losing on high devices.");
	
	command.setQuery(@"thin").optional().setExample(@"armv7|arm64").setExplain(@"Thin binary");
	command.setQuery(@"inject").setAbbr('I').optional().setMultiType(CLQueryMultiTypeMoreKeyValue).setExample(@"/path/to/dylib").setExplain(@"Inject dylib(s) into binary.");
	
	command.setFlag(@"rm-plugins").setExplain(@"Delete all app extensions.");
	command.setFlag(@"rm-watches").setExplain(@"Delete all watch apps.");
	command.setFlag(@"rm-ext").setAbbr('r').setExplain(@"Delete all watch apps and plugins.");
	command.setFlag(@"replace").setAbbr('R').setExplain(@"Sign and replace input file.");
	
	command.setQuery(@"entitlements").setAbbr('e').optional().setMultiType(CLQueryMultiTypeMoreKeyValue).setExplain(@"Sign with entitlements, bundle_id=entitlement_path");
	command.setQuery(@"get-task-allow").setAbbr('D').optional().setExample(@"1|0").setExplain(@"Modify `get-task-allow` in entitlements.");
	
	command.addRequirePath(@"input").setExample(@"/path/to/input.ipa").setExplain(@"Input ipa path.");
	command.addOptionalPath(@"output").setExample(@"/path/to/output.ipa").setExplain(@"Output ipa path.");
}

+ (ISIPASignerOptions *)genSignOptionsFromProcess:(CLProcess *)process {
    ISIPASignerOptions *options = [ISIPASignerOptions new];
	options.CFBundleIdentifier = process.queries[@"bundle-id"];
	options.CFBundleVersion = process.queries[@"bundle-version"];
	options.CFBundleDisplayName = process.queries[@"bundle-display-name"];
	options.CFBundleShortVersionString = process.queries[@"build-version"];
	options.deletePlugIns = [process flag:@"rm-plugins"];
	options.deleteWatches = [process flag:@"rm-watches"];
	options.deleteExtensions = [process flag:@"rm-ext"];
	options.supportAllDevices = [process flag:@"support-all-devices"];
	options.fixIcons = [process flag:@"fix-icons"];
	options.getTaskAllow = process.queries[@"get-task-allow"];
	options.replace = [process flag:@"replace"];
	
	ISMachOPlatform thin = process.queries[@"thin"];
	if (thin && [@[ISMachOPlatformArmV7, ISMachOPlatformArm64] containsObject:thin]) {
		options.thin = thin;
	}
	NSArray<NSString *> *injectDylibs = process.queries[@"inject"];
	if (injectDylibs.count) {
		NSMutableArray *list = [NSMutableArray array];
		[injectDylibs enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			[list addObject:[MUPath pathWithString:obj]];
		}];
		options.injectDylibs = [list copy];
	}
	
	if ([process flag:@"file-sharing"] && [process flag:@"no-file-sharing"]) {
		CLError(@"You must type in one of --file-sharing and --no-file-sharing, or without anyone.");
		CLExit(EXIT_FAILURE);
	}
	else if ([process flag:@"file-sharing"]) {
		options.enableiTunesFileSharing = YES;
	}
	else if ([process flag:@"no-file-sharing"]) {
		options.disableiTunesFileSharing = YES;
	}
	
	if ([process flag:@"file-place"] && [process flag:@"no-file-place"]) {
		CLError(@"You must type in one of --file-place and --no-file-place, or without anyone.");
		CLExit(EXIT_FAILURE);
	}
	else if ([process flag:@"file-place"]) {
		options.enableSupportsOpeningDocumentsInPlace = YES;
	}
	else if ([process flag:@"no-file-place"]) {
		options.disableSupportsOpeningDocumentsInPlace = YES;
	}
	
	NSDictionary *entitlements = ({
		NSMutableDictionary *entitlements = nil;
		if (process.queries[@"entitlements"]) {
			entitlements = [NSMutableDictionary dictionary];
			NSArray *list = process.queries[@"entitlements"];
			for (NSString *item in list) {
				NSArray *components = [item componentsSeparatedByString:@"="];
				if (components.count != 2) {
					entitlements[ISIPAMainBundleIdentifier] = [MUPath pathWithString:components.lastObject];
				} else {
					entitlements[components.firstObject] = [MUPath pathWithString:components.lastObject];
				}
			}
		}
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


+ (MUPath *)inputPathFromProcess:(CLProcess *)process {
	MUPath *input = [MUPath pathWithString:[process pathForIndex:0]];
	return input;
}

+ (MUPath *)outputPathFromProcess:(CLProcess *)process {
	MUPath *input = [MUPath pathWithString:[process pathForIndex:0]];
	MUPath *output = [process pathForIndex:1] ? [MUPath pathWithString:[process pathForIndex:1]] : [input pathByReplacingPathExtension:@"signed.ipa"];
	return output;
}

@end
