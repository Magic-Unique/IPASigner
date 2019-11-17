//
//  IPASigner.h
//  IPASigner
//
//  Created by 冷秋 on 2019/9/17.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ISIPASigner.h"

NS_ASSUME_NONNULL_BEGIN

@interface IPASigner : NSObject

+ (void)addGeneralArgumentsToCommand:(CLCommand *)command;

+ (ISIPASignerOptions *)genSignOptionsFromProcess:(CLProcess *)process;

+ (MUPath *)inputPathFromProcess:(CLProcess *)process;

+ (MUPath *)outputPathFromProcess:(CLProcess *)process;

@end

NS_ASSUME_NONNULL_END
