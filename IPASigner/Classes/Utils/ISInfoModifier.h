//
//  ISInfoModifier.h
//  IPASigner
//
//  Created by 冷秋 on 2019/10/18.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ISInfoModifier : NSObject

+ (void)setBundle:(MUPath *)bundle bundleID:(NSString *)bundleID;

+ (void)setBundle:(MUPath *)bundle iTunesFileSharingEnable:(BOOL)enable;

+ (void)setBundle:(MUPath *)bundle bundleShortVersionString:(NSString *)version;

+ (void)setBundle:(MUPath *)bundle bundleVersion:(NSString *)version;

+ (void)setBundle:(MUPath *)bundle supportAllDevices:(BOOL)supportAllDevices;

+ (void)setBundle:(MUPath *)bundle bundleDisplayName:(NSString *)bundleDisplayName;

@end
