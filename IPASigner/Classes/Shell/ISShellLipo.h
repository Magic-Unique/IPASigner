//
//  ISShellLipo.h
//  IPASigner
//
//  Created by 吴双 on 2021/7/14.
//  Copyright © 2021 Magic-Unique. All rights reserved.
//

#import "ISShellPath.h"

FOUNDATION_EXTERN BOOL ISLipoThin(NSString *binary, NSString *platform, NSString *output);

FOUNDATION_EXTERN NSArray<NSString *> *ISLipoArchs(NSString *binary);
