//
//  ProvisionPrune.m
//  IPASigner
//
//  Created by 吴双 on 2026/3/6.
//  Copyright © 2026 Magic-Unique. All rights reserved.
//

#import "ProvisionPrune.h"
#import "ISProvisionManager.h"

@implementation ProvisionPrune

command_configuration(command) {
	command.name = @"prune";
	command.note = @"Uninstall all expired or old profile.";
}

command_main() {
	
	ISProvisionManager *provisionMgr = [ISProvisionManager sharedInstance];
	
	NSDictionary *map = [provisionMgr.installedProvisions signer_mergeWithKeyPath:@"provision.Name" sort:^NSComparisonResult(ISProvision *obj1, ISProvision *obj2) {
		return [obj1.provision.CreationDate compare:obj2.provision.CreationDate];
	}];
	[map enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSMutableArray<ISProvision *> *obj, BOOL * _Nonnull stop) {
		__auto_type last = obj.lastObject;
		[obj removeLastObject];
		[obj enumerateObjectsUsingBlock:^(ISProvision *obj, NSUInteger idx, BOOL * _Nonnull stop) {
			CLInfo(@"Remove old %@ (%@)", obj.provision.UUID, obj.provision.Name);
			[obj.path remove];
		}];
		if ([last.provision.ExpirationDate timeIntervalSinceNow] < 0) {
			CLInfo(@"Remove expire %@ (%@)", last.provision.UUID, last.provision.Name);
			[last.path remove];
		}
	}];
	return 0;
}

@end
