//
//  MUPath+IPA.m
//  IPASigner
//
//  Created by 冷秋 on 2019/10/12.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import "MUPath+IPA.h"
#import <MachOKit/MachOKit.h>
#import <AppKit/AppKit.h>

@implementation MUPath (IPA)

- (MUPath *)infoPath {
    if (self.isDirectory) {
        MUPath *infoPath = [self subpathWithComponent:@"Info.plist"];
        if (infoPath.isFile) {
            return infoPath;
        }
    }
    return nil;
}

- (NSDictionary *)info {
    MUPath *infoPath = self.infoPath;
    if (infoPath) {
        return [NSDictionary dictionaryWithContentsOfFile:infoPath.string];
    }
    return nil;
}

- (id)infoObjectForKey:(NSString *)key {
	return self.info[key];
}

- (void)setInfoObject:(id)object forKey:(NSString *)key {
	MUPath *infoPath = self.infoPath;
	if (infoPath) {
		NSMutableDictionary *info = [NSMutableDictionary dictionaryWithContentsOfFile:infoPath.string];
		info[key] = object;
		[info writeToFile:infoPath.string atomically:YES];
	}
}

- (MUPath *)CFBundleExecutable {
    NSDictionary *info = self.info;
	if (!info) {
		return nil;
	}
	NSString *CFBundleExecutable = info[@"CFBundleExecutable"];
	if (!CFBundleExecutable) {
		return nil;
	}
    return [self subpathWithComponent:CFBundleExecutable];
}

- (NSString *)CFBundleIdentifier {
	return [self infoObjectForKey:@"CFBundleIdentifier"];
}

- (void)setCFBundleIdentifier:(NSString *)CFBundleIdentifier {
	[self setInfoObject:CFBundleIdentifier forKey:@"CFBundleIdentifier"];
}

- (NSString *)CFBundleShortVersionString {
	return [self infoObjectForKey:@"CFBundleShortVersionString"];
}

- (void)setCFBundleShortVersionString:(NSString *)CFBundleShortVersionString {
	[self setInfoObject:CFBundleShortVersionString forKey:@"CFBundleShortVersionString"];
}

- (NSString *)CFBundleVersion {
	return [self infoObjectForKey:@"CFBundleVersion"];
}

- (void)setCFBundleVersion:(NSString *)CFBundleVersion {
	[self setInfoObject:CFBundleVersion forKey:@"CFBundleVersion"];
}

- (NSString *)CFBundleDisplayName {
	return [self infoObjectForKey:@"CFBundleDisplayName"];
}

- (void)setCFBundleDisplayName:(NSString *)CFBundleDisplayName {
	[self setInfoObject:CFBundleDisplayName forKey:@"CFBundleDisplayName"];
}

- (BOOL)UIFileSharingEnabled {
	return [self.info[@"UIFileSharingEnabled"] boolValue];
}

- (void)setUIFileSharingEnabled:(BOOL)UIFileSharingEnabled {
	[self __setInfo:^(NSMutableDictionary *info) {
		if (UIFileSharingEnabled) {
			info[@"UIFileSharingEnabled"] = @YES;
		} else {
			info[@"UIFileSharingEnabled"] = nil;
			info[@"LSSupportsOpeningDocumentsInPlace"] = nil;
		}
	}];
}

- (BOOL)LSSupportsOpeningDocumentsInPlace {
	return [self.info[@"LSSupportsOpeningDocumentsInPlace"] boolValue] && self.UIFileSharingEnabled;
}

- (void)setLSSupportsOpeningDocumentsInPlace:(BOOL)LSSupportsOpeningDocumentsInPlace {
	[self __setInfo:^(NSMutableDictionary *info) {
		if (LSSupportsOpeningDocumentsInPlace) {
			info[@"LSSupportsOpeningDocumentsInPlace"] = @YES;
			info[@"UIFileSharingEnabled"] = @YES;
		} else {
			info[@"LSSupportsOpeningDocumentsInPlace"] = nil;
		}
	}];
}

- (void)supportAllDevices {
	MUPath *infoPath = self.infoPath;
	if (infoPath) {
		NSMutableDictionary *info = [NSMutableDictionary dictionaryWithContentsOfFile:infoPath.string];
		NSMutableArray *UISupportedDevices = info[@"UISupportedDevices"];
		if (UISupportedDevices) {
			[info removeObjectForKey:@"UISupportedDevices"];
			[info writeToFile:infoPath.string atomically:YES];
		}
	}
}

- (void)fixIcons:(MUPath *)targetIcon {
	if (!targetIcon) {
		NSArray<MUPath *> *list = [self contentsWithFilter:^BOOL(MUPath *content) {
			return [content isA:@"png"] && [content.lastPathComponent hasPrefix:@"AppIcon"];
		}];
		if (list.count == 0) {
			return;
		}
		NSSize maxSize = NSZeroSize;
		MUPath *maxItem = nil;
		for (MUPath *item in list) {
			NSImage *image = [[NSImage alloc] initWithContentsOfFile:item.string];
			if (!maxItem || image.size.width > maxSize.width) {
				maxItem = item;
				maxSize = image.size;
			}
		}
		targetIcon = maxItem;
	}
	
	if (!targetIcon) {
		return;
	}
	NSArray *iconNames = @[@"icon.png", @"icon@2x.png", @"icon@3x.png"];
	NSMutableDictionary *info = [NSMutableDictionary dictionaryWithContentsOfFile:self.infoPath.string];
	info[@"CFBundleIcons"] = nil;
	info[@"CFBundleIcons~ipad"] = nil;
	info[@"CFBundleIconFiles"] = iconNames;
	[info writeToFile:self.infoPath.string atomically:YES];
	for (NSString *iconName in iconNames) {
		MUPath *target = [self subpathWithComponent:iconName];
		[targetIcon copyTo:target autoCover:YES];
	}
}

- (BOOL)isApp {
    return self.isDirectory && [self isA:@"app"];
}

- (BOOL)isAppex {
    return self.isDirectory && [self isA:@"appex"];
}

- (BOOL)isFramework {
    return self.isDirectory && [self isA:@"framework"];
}

- (BOOL)isDylib {
    return self.isFile && [self isA:@"dylib"];
}

- (MUPath *)pluginsDirectory {
    if (!self.isApp) {
        return nil;
    }
    MUPath *path = [self subpathWithComponent:@"PlugIns"];
    if (path.isDirectory) {
        return path;
    }
    return nil;
}

- (MUPath *)watchDirectory {
    if (!self.isApp) {
        return nil;
    }
    MUPath *path = [self subpathWithComponent:@"Watch"];
    if (path.isDirectory) {
        return path;
    }
    return nil;
}

- (MUPath *)watchPlaceholderDirectory {
    if (!self.isApp) {
        return nil;
    }
    MUPath *path = [self subpathWithComponent:@"com.apple.WatchPlaceholder"];
	if (path.isDirectory) {
		return path;
	}
    return nil;
}

- (NSArray<MUPath *> *)allPlugInApps {
	if (!self.isApp) {
		return nil;
	}
    MUPath *PluginsPath = self.pluginsDirectory;
	if (PluginsPath.isDirectory) {
		NSMutableArray *_plugins = [NSMutableArray array];
		[PluginsPath enumerateContentsUsingBlock:^(MUPath *content, BOOL *stop) {
			if (content.isAppex) {
				[_plugins addObject:content];
			}
		}];
		return [_plugins copy];
	}
	return nil;
}

- (NSArray<MUPath *> *)allWatchApps {
	if (!self.isApp) {
		return nil;
	}
	NSMutableArray *_watches = [NSMutableArray array];
	[self.watchDirectory enumerateContentsUsingBlock:^(MUPath *content, BOOL *stop) {
		if (content.isApp) {
			[_watches addObject:content];
		}
	}];
	[self.watchPlaceholderDirectory enumerateContentsUsingBlock:^(MUPath *content, BOOL *stop) {
		if (content.isApp) {
			[_watches addObject:content];
		}
	}];
	return [_watches copy];
}

- (NSArray<NSString *> *)allBundleIdentifiers {
	NSMutableArray *array = [NSMutableArray array];
	if (self.isApp) {
		[array addObject:self.CFBundleIdentifier];
	}
	[self.allPlugInApps enumerateObjectsUsingBlock:^(MUPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		[array addObjectsFromArray:obj.allBundleIdentifiers];
	}];
	[self.allWatchApps enumerateObjectsUsingBlock:^(MUPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		[array addObjectsFromArray:obj.allBundleIdentifiers];
	}];
	return [array copy];
}

- (NSArray<MUPath *> *)loadedLibraries {
	return [self loadedLibrariesWithExecuter:self];
}

- (NSArray<MUPath *> *)loadedLibrariesWithExecuter:(MUPath *)executer {
	guard (self.isFile && executer.isFile) else {
		return nil;
	}
	
	NSMutableSet *links = [NSMutableSet set];
	NSMutableArray *loads = [NSMutableArray array];
	NSMutableArray *rpaths = [NSMutableArray array];
	@autoreleasepool {
		NSURL *URL = self.fileURL;
		MKMemoryMap *map = [MKMemoryMap memoryMapWithContentsOfFile:URL error:nil];
		MKFatBinary *fatBinary = [[MKFatBinary alloc] initWithMemoryMap:map error:nil];
		MKMachOImage *macho = [[MKMachOImage alloc] initWithName:URL.lastPathComponent.UTF8String
														   flags:kNilOptions
													   atAddress:fatBinary.architectures.lastObject.offset
													   inMapping:map
														   error:nil];
		for (MKLoadCommand *loadCommand in macho.loadCommands) {
			if ([loadCommand isKindOfClass:[MKDylibLoadCommand class]] && loadCommand.cmd == LC_LOAD_DYLIB) {
				MKDylibLoadCommand *dylibLoadCommand = (MKDylibLoadCommand *)loadCommand;
				NSString *path = dylibLoadCommand.name.string;
				if ([path hasPrefix:@"@"]) {
					[loads addObject:path];
				}
			}
			else if ([loadCommand isKindOfClass:[MKLCRPath class]]) {
				MKLCRPath *rpath = (MKLCRPath *)loadCommand;
				NSString *path = rpath.path.string;
				if (![path hasPrefix:@"/"]) { // Ignore system rpath
					[rpaths addObject:path];
				}
			}
		}
	}
	
	NSString *executable_path = executer.superpath.string;
	NSString *loader_path = self.superpath.string;
#define AddPathToLink(p, l) if ([p.superpath isA:@"framework"]) { [l addObject:p.superpath.string]; } else { [l addObject:p.string]; } [l addObjectsFromArray:[p loadedLibrariesWithExecuter:executer]]
	for (NSString *load in loads) {
		//				if ([load.lastPathComponent isEqualToString:self.lastPathComponent]) { has filt LC_ID_DYLIB
		//					continue;
		//				}
		if ([load hasPrefix:@"@executable_path"]) {
			MUPath *path = [MUPath pathWithString:[load stringByReplacingOccurrencesOfString:@"@executable_path"
																				  withString:executable_path]];
			if (path.isFile) {
				AddPathToLink(path, links);
			} else {
				CLError(@"The file is not exist 1: %@", path.string);
			}
		}
		else if ([load hasPrefix:@"@loader_path"]) {
			MUPath *path = [MUPath pathWithString:[load stringByReplacingOccurrencesOfString:@"@loader_path"
																				  withString:loader_path]];
			if (path.isFile) {
				AddPathToLink(path, links);
			} else {
				CLError(@"The file is not exist 2: %@", path.string);
			}
		}
		else if ([load hasPrefix:@"@rpath"]) {
			for (NSString *rpath in rpaths) {
				NSString *temp = load;
				temp = [temp stringByReplacingOccurrencesOfString:@"@rpath" withString:rpath];
				temp = [temp stringByReplacingOccurrencesOfString:@"@executable_path" withString:executable_path];
				temp = [temp stringByReplacingOccurrencesOfString:@"@loader_path" withString:loader_path];
				MUPath *path = [MUPath pathWithString:temp];
				if (path.isFile) {
					AddPathToLink(path, links);
					break;
				}
			}
		}
	}
#undef AddPathToLink
	
	NSString *bundle = executer.superpath.string;
	[links filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
		if ([evaluatedObject hasPrefix:bundle]) {
			CLVerbose(@"Add %@", evaluatedObject);
			return YES;
		} else {
			CLVerbose(@"Ignore %@", evaluatedObject);
			return NO;
		}
	}]];
	return links.allObjects;
}

- (BOOL)__setInfo:(void (^)(NSMutableDictionary *info))block {
	MUPath *infoPath = self.infoPath;
	if (infoPath) {
		NSMutableDictionary *info = [NSMutableDictionary dictionaryWithContentsOfFile:infoPath.string];
		block(info);
		[info writeToFile:self.infoPath.string atomically:YES];
		return YES;
	}
	return NO;
}

@end
