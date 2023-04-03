//
//  ISAuthManager.h
//  IPASigner
//
//  Created by 吴双 on 2023/2/9.
//  Copyright © 2023 Magic-Unique. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ISAuthName : NSObject

@property (nonatomic, strong) NSString *appleID;
@property (nonatomic, strong) NSString *accountName;

@property (nonatomic, strong) NSString *teamName;
@property (nonatomic, strong) NSString *teamIdentifier;

@property (nonatomic, strong) NSString *alias;

@end


@interface ISAuthManager : NSObject

@property (nonatomic, strong, readonly) NSArray<ISAuthName *> *names;

- (void)logout:(NSString *)accountIdentifier;

- (NSError *)add:(ISAuthName *)name;
- (NSError *)remove:(ISAuthName *)name;

- (ISAuthName *)nameForAlias:(NSString *)alias;

@end
