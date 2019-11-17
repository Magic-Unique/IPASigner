//
//  main.m
//  IPASigner
//
//  Created by 冷秋 on 2019/9/17.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IPASigner.h"

int main(int argc, const char * argv[]) {
	@autoreleasepool {
		CLCommand.mainCommand.explain = @"An signer tools for ipa file.";
		CLCommand.mainCommand.version = @"1.0.0";
		CLCommand.parametersSortType = CLSortTypeByAddingQueue;
		CLMakeSubcommand(IPASigner, __init_);
		return [CLCommand process];
    }
    return 0;
}
