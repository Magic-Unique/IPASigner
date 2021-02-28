//
//  ISIPASigner.h
//  IPASigner
//
//  Created by 冷秋 on 2019/10/20.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ISProvision.h"
#import "ISIdentity.h"
#import "ISEntitlements.h"

@interface ISIPASignerOptions : NSObject

@property (nonatomic, copy) NSString *CFBundleIdentifier;

@property (nonatomic, copy) NSString *CFBundleShortVersionString;
@property (nonatomic, copy) NSString *CFBundleVersion;
@property (nonatomic, copy) NSString *CFBundleDisplayName;

@property (nonatomic, assign) BOOL deletePlugIns;
@property (nonatomic, assign) BOOL deleteWatches;
@property (nonatomic, assign) BOOL deleteExtensions;

@property (nonatomic, assign) BOOL enableiTunesFileSharing;
@property (nonatomic, assign) BOOL disableiTunesFileSharing;

@property (nonatomic, assign) BOOL fixIcons;

@property (nonatomic, assign) BOOL supportAllDevices;

@property (nonatomic, assign) BOOL ignoreSign;

@property (nonatomic, copy) ISProvision *(^provisionForBundle)(MUPath *bundle);

@property (nonatomic, copy) ISEntitlements *(^entitlementsForBundle)(MUPath *bundle);

@property (nonatomic, copy) ISIdentity *(^identityForProvision)(ISProvision *provision, NSArray<ISIdentity *> *identities);

@end

@interface ISIPASigner : NSObject

+ (BOOL)sign:(MUPath *)ipaInput options:(ISIPASignerOptions *)options output:(MUPath *)ipaOutput;

@end
