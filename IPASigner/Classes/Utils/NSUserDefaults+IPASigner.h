//
//  NSUserDefaults+IPASigner.h
//  IPASigner
//
//  Created by 吴双 on 2020/5/16.
//  Copyright © 2020 Magic-Unique. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (IPASigner)

- (void)setObject:(NSString *)obj forKeyedSubscript:(NSString *)key;

- (id)objectForKeyedSubscript:(NSString *)key;

@end
