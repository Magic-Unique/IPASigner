//
//  MUPath+IPA.m
//  IPASigner
//
//  Created by 冷秋 on 2019/10/12.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import "MUPath+IPA.h"
#import <MachOKit/MachOKit.h>

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
    return [self subpathWithComponent:info[@"CFBundleExecutable"]];
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
	MUPath *infoPath = self.infoPath;
	if (infoPath) {
		NSMutableDictionary *info = [NSMutableDictionary dictionaryWithContentsOfFile:infoPath.string];
		info[@"UIFileSharingEnabled"] = @(UIFileSharingEnabled);
		[info writeToFile:self.infoPath.string atomically:YES];
	}
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
    if (self.isFile && executer.isFile) {
		NSMutableSet *links = [NSMutableSet set];
		@autoreleasepool {
			NSMutableArray *loads = [NSMutableArray array];
			NSMutableArray *rpaths = [NSMutableArray array];
			NSURL *URL = self.fileURL;
			MKMemoryMap *map = [MKMemoryMap memoryMapWithContentsOfFile:URL error:nil];
			MKFatBinary *fatBinary = [[MKFatBinary alloc] initWithMemoryMap:map error:nil];
			MKMachOImage *macho = [[MKMachOImage alloc] initWithName:URL.lastPathComponent.UTF8String
															   flags:kNilOptions
														   atAddress:fatBinary.architectures.lastObject.offset
														   inMapping:map
															   error:nil];
			for (MKLoadCommand *loadCommand in macho.loadCommands) {
				if ([loadCommand isKindOfClass:[MKDylibLoadCommand class]]) {
					MKDylibLoadCommand *dylibLoadCommand = (MKDylibLoadCommand *)loadCommand;
					NSString *path = dylibLoadCommand.name.string;
					if ([path hasPrefix:@"@"]) {
						[loads addObject:path];
					}
				}
				else if ([loadCommand isKindOfClass:[MKLCRPath class]]) {
					MKLCRPath *rpath = (MKLCRPath *)loadCommand;
					[rpaths addObject:rpath.path.string];
				}
			}
			
			NSString *executable_path = executer.superpath.string;
			NSString *loader_path = self.superpath.string;
			for (NSString *load in loads) {
				if ([load.lastPathComponent isEqualToString:self.lastPathComponent]) {
					continue;
				}
				if ([load hasPrefix:@"@executable_path"]) {
					MUPath *path = [MUPath pathWithString:[load stringByReplacingOccurrencesOfString:@"@executable_path"
																						  withString:executable_path]];
					if (path.isFile) {
						if ([path.superpath isA:@"framework"]) {
							[links addObject:path.superpath.string];
						} else {
							[links addObject:path.string];
						}
						[links addObjectsFromArray:[path loadedLibrariesWithExecuter:executer]];
					} else {
						CLError(@"The file is not exist 1: %@", path.string);
					}
				}
				else if ([load hasPrefix:@"@loader_path"]) {
					MUPath *path = [MUPath pathWithString:[load stringByReplacingOccurrencesOfString:@"@loader_path"
																						  withString:loader_path]];
					if (path.isFile) {
						if ([path.superpath isA:@"framework"]) {
							[links addObject:path.superpath.string];
						} else {
							[links addObject:path.string];
						}
						[links addObjectsFromArray:[path loadedLibrariesWithExecuter:executer]];
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
							if ([path.superpath isA:@"framework"]) {
								[links addObject:path.superpath.string];
							} else {
								[links addObject:path.string];
							}
							[links addObjectsFromArray:[path loadedLibrariesWithExecuter:executer]];
							break;
						}
					}
				}
			}
		}
		
		NSMutableArray *_list = links.allObjects.mutableCopy;
		NSString *bundle = executer.superpath.string;
		for (NSUInteger i = 0; i < _list.count; i++) {
			NSString *path = _list[i];
			if (![path hasPrefix:bundle]) {
				[_list removeObjectAtIndex:i--];
				CLVerbose(@"Ignore %@", path);
			} else {
				CLVerbose(@"Add %@", path);
			}
		}
		return _list;
    }
    return nil;
}

@end
