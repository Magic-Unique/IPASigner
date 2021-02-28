//
//  MUPath+IPA.h
//  IPASigner
//
//  Created by 冷秋 on 2019/10/12.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import "MUPath+Main.h"

@interface MUPath (IPA)

@property (nonatomic, strong, readonly) MUPath *infoPath;

@property (nonatomic, strong, readonly) NSDictionary *info;

@property (nonatomic, strong, readonly) MUPath *CFBundleExecutable;

@property (nonatomic, assign, readonly) BOOL isApp;
@property (nonatomic, assign, readonly) BOOL isAppex;
@property (nonatomic, assign, readonly) BOOL isFramework;
@property (nonatomic, assign, readonly) BOOL isDylib;

@property (nonatomic, strong, readonly) MUPath *pluginsDirectory;
@property (nonatomic, strong, readonly) MUPath *watchDirectory;
@property (nonatomic, strong, readonly) MUPath *watchPlaceholderDirectory;

@property (nonatomic, strong, readonly) NSArray<MUPath *> *allPlugInApps;
@property (nonatomic, strong, readonly) NSArray<MUPath *> *allWatchApps;

@property (nonatomic, strong, readonly) NSArray<NSString *> *allBundleIdentifiers;

@property (nonatomic, strong) NSString *CFBundleIdentifier;
@property (nonatomic, strong) NSString *CFBundleShortVersionString;
@property (nonatomic, strong) NSString *CFBundleVersion;
@property (nonatomic, strong) NSString *CFBundleDisplayName;

@property (nonatomic, assign) BOOL UIFileSharingEnabled;

@property (nonatomic, strong, readonly) NSArray<MUPath *> *loadedLibraries;

- (NSArray<MUPath *> *)loadedLibrariesWithExecuter:(MUPath *)executer;

- (void)supportAllDevices;

- (void)fixIcons;

@end
