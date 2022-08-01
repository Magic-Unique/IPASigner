//
//  ISInfoModifier.m
//  IPASigner
//
//  Created by 冷秋 on 2019/10/18.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import "ISInfoModifier.h"
#import "MUPath+IPA.h"

@implementation ISInfoModifier

+ (void)setBundle:(MUPath *)bundle bundleID:(NSString *)bundleID {
	NSString *newMainBundleID = bundleID;
	NSString *oldMainBundleID = bundle.CFBundleIdentifier;
	
	CLInfo(@"Set %@ bundle id: %@", bundle.lastPathComponent, newMainBundleID);
	bundle.CFBundleIdentifier = newMainBundleID;
	
	if (bundle.isApp) {
		[bundle.allPlugInApps enumerateObjectsUsingBlock:^(MUPath * _Nonnull appex, NSUInteger idx, BOOL * _Nonnull stop) {
			NSString *oldAppexBundleID = appex.CFBundleIdentifier;
			NSString *newAppexBundleID = [oldAppexBundleID stringByReplacingOccurrencesOfString:oldMainBundleID withString:newMainBundleID];
			[self setBundle:appex bundleID:newAppexBundleID];
		}];
		[bundle.allWatchApps enumerateObjectsUsingBlock:^(MUPath * _Nonnull watch, NSUInteger idx, BOOL * _Nonnull stop) {
			NSString *oldWatchBundleID = watch.CFBundleIdentifier;
			NSString *newWatchBundleID = [oldWatchBundleID stringByReplacingOccurrencesOfString:oldMainBundleID withString:newMainBundleID];
			[self setBundle:watch bundleID:newWatchBundleID];
		}];
	}
}

+ (void)setBundle:(MUPath *)bundle iTunesFileSharingEnable:(BOOL)enable {
	CLInfo(@"%@ iTunes file sharing.", enable ? @"Enable" : @"Disable");
	bundle.UIFileSharingEnabled = enable;
}

+ (void)setBundle:(MUPath *)bundle supportsOpeningDocumentsInPlace:(BOOL)supportsOpeningDocumentsInPlace {
	CLInfo(@"%@ open documents in place", supportsOpeningDocumentsInPlace ? @"Enable" : @"Disable");
	bundle.LSSupportsOpeningDocumentsInPlace = supportsOpeningDocumentsInPlace;
}

+ (void)setBundle:(MUPath *)bundle bundleShortVersionString:(NSString *)version {
	CLInfo(@"Set %@ short version: %@", bundle.lastPathComponent, version);
	bundle.CFBundleShortVersionString = version;
	
	if (bundle.isApp) {
		[bundle.allPlugInApps enumerateObjectsUsingBlock:^(MUPath * _Nonnull appex, NSUInteger idx, BOOL * _Nonnull stop) {
			[self setBundle:appex bundleShortVersionString:version];
		}];
		[bundle.allWatchApps enumerateObjectsUsingBlock:^(MUPath * _Nonnull watch, NSUInteger idx, BOOL * _Nonnull stop) {
			[self setBundle:watch bundleShortVersionString:version];
		}];
	}
}

+ (void)setBundle:(MUPath *)bundle bundleVersion:(NSString *)version {
	CLInfo(@"Set %@ version: %@", bundle.lastPathComponent, version);
	bundle.CFBundleVersion = version;
	
	if (bundle.isApp) {
		[bundle.allPlugInApps enumerateObjectsUsingBlock:^(MUPath * _Nonnull appex, NSUInteger idx, BOOL * _Nonnull stop) {
			[self setBundle:appex bundleVersion:version];
		}];
		[bundle.allWatchApps enumerateObjectsUsingBlock:^(MUPath * _Nonnull watch, NSUInteger idx, BOOL * _Nonnull stop) {
			[self setBundle:watch bundleVersion:version];
		}];
	}
}

+ (void)setBundle:(MUPath *)bundle supportAllDevices:(BOOL)supportAllDevices {
	if (supportAllDevices) {
		CLInfo(@"Remove UISupportedDevices");
		[bundle supportAllDevices];
	}
}

+ (void)setBundle:(MUPath *)bundle bundleDisplayName:(NSString *)bundleDisplayName {
	CLInfo(@"Set %@ display name: %@", bundle.lastPathComponent, bundleDisplayName);
	bundle.CFBundleDisplayName = bundleDisplayName;
	[bundle enumerateContentsUsingBlock:^(MUPath *content, BOOL *stop) {
		if (!content.isDirectory || ![content isA:@"lproj"]) {
			return;
		}
		
		MUPath *InfoPlist_string = [content subpathWithComponent:@"InfoPlist.strings"];
		if (!InfoPlist_string.isFile) {
			return;
		}
		
		NSMutableDictionary *info = [NSMutableDictionary dictionaryWithContentsOfFile:InfoPlist_string.string];
		if (!info[@"CFBundleDisplayName"]) {
			return;
		}
		
		info[@"CFBundleDisplayName"] = bundleDisplayName;
		[info writeToFile:InfoPlist_string.string atomically:YES];
	}];
}

@end
