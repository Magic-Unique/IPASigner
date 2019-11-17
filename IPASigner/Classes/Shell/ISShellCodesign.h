//
//  ISShellCodesign.h
//  IPASigner
//
//  Created by 冷秋 on 2019/9/17.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import "ISShellPath.h"

FOUNDATION_EXTERN BOOL ISCodesign(NSString *identity, BOOL force, BOOL verify, NSString *entitlements, NSString *path);

FOUNDATION_EXTERN NSDictionary *ISCodesignDisplayEntitlements(NSString *path);
