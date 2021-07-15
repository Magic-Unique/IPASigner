//
//  ISShellPath.h
//  IPASigner
//
//  Created by 冷秋 on 2019/9/17.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IS_PATH_XCODE			(ISSelectedXcodePath())

#define IS_BIN_SECURITY			@"/usr/bin/security"
#define IS_BIN_CODESIGN			@"/usr/bin/codesign"
#define IS_BIN_ZIP				@"/usr/bin/zip"
#define IS_BIN_UNZIP			@"/usr/bin/unzip"
#define IS_BIN_MKTEMP			@"/usr/bin/mktemp"
#define IS_BIN_XCODE_SELECT		@"/usr/bin/xcode-select"
#define IS_BIN_LIPO				@"/usr/bin/lipo"
#define IS_BIN_CHMOD			@"/bin/chmod"

#define IS_BIN_OTOOL			(ISXcodeBinPath(@"XcodeDefault", @"/usr/bin/otool"))

FOUNDATION_EXTERN NSString *ISSelectedXcodePath(void);

FOUNDATION_EXTERN NSString *ISXcodeBinPath(NSString *toolchain, NSString *bin);

FOUNDATION_EXTERN NSString *ISShellLaunch(NSString *at, NSString *bin, void (^concat)(NSMutableArray *arguments));
