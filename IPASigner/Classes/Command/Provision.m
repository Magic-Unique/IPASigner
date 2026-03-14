//
//  Provision.m
//  IPASigner
//
//  Created by 吴双 on 2026/3/6.
//  Copyright © 2026 Magic-Unique. All rights reserved.
//

#import "Provision.h"
#import "ProvisionList.h"
#import "ProvisionPrune.h"

@implementation Provision

command_configuration(provision) {
	provision.note = @"CRUD for *.mobileprovision";
	provision.subcommands = @[[ProvisionList class], [ProvisionPrune class]];
}

@end
