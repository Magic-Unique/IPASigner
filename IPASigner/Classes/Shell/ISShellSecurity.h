//
//  ISShellSecurity.h
//  IPASigner
//
//  Created by 冷秋 on 2019/9/17.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import "ISShellPath.h"

typedef NSString *ISSecurityPolicy;

FOUNDATION_EXTERN ISSecurityPolicy ISSecurityCodesigningPolicy;

FOUNDATION_EXTERN NSArray *ISSecurityFindIdentity(ISSecurityPolicy policy, BOOL valid);
