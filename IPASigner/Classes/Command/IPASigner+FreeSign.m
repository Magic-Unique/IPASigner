//
//  IPASigner+FreeSign.m
//  IPASigner
//
//  Created by 吴双 on 2023/2/9.
//  Copyright © 2023 Magic-Unique. All rights reserved.
//

#import "IPASigner+FreeSign.h"
#import <AppleSession/AppleSession.h>
#import <AltSign/AltSign.h>

#define ALT_PLUGIN_VERSION_URL @"https://cdn.altstore.io/file/altstore/altserver/altplugin/altplugin.json"

@implementation IPASigner (FreeSign)

+ (void)__init_installMailPlugin {
	CLCommand *install = [[CLCommand mainCommand] defineSubcommand:@"install-mail-plugin"];
	install.explain = @"Install AltPlugin to Mail";
	[install handleProcess:^int(CLCommand * _Nonnull command, CLProcess * _Nonnull process) {
		MUPath *path = [MUPath pathWithString:@"/Library/Mail/Bundles/AltPlugin.mailbundle"];
		if (path.isDirectory) {
			CLInfo(@"The mail plugin has installed.");
			return EXIT_SUCCESS;
		}
		
		NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:ALT_PLUGIN_VERSION_URL]];
		NSDictionary *version = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
		NSDictionary *pluginVersion = version[@"pluginVersion"];
		NSString *url = pluginVersion[@"url"];
		NSURL *URL = [NSURL URLWithString:url];
		[[NSURLSession.sharedSession downloadTaskWithURL:URL
									   completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
			
		}] resume];
		[[NSRunLoop currentRunLoop] run];
		return EXIT_SUCCESS;
	}];
}

+ (void)__init_login {
	CLCommand *login = [[CLCommand mainCommand] defineSubcommand:@"login"];
	login.explain = @"Login an Apple ID to generate free certificate.";
	login.setQuery(@"account").setAbbr('i').setExplain(@"The AppleID");
	login.setQuery(@"password").setAbbr('p').setExplain(@"The AppleID password");
	[login handleProcess:^int(CLCommand * _Nonnull command, CLProcess * _Nonnull process) {
		NSString *ACCOUNT = process.queries[@"account"];
		NSString *PASSWORD = process.queries[@"password"];
		ASSessionManager *mgr = [[ASSessionManager alloc] init];
		CLInfo(@"Login to Apple server...");
		[mgr login:ACCOUNT password:PASSWORD verify:^(void (^verify)(NSString *)) {
			
		} completed:^(ASAccountSession *accountSession, NSError *error) {
			if (error) {
				CLError(@"Login failed: %@", error.localizedDescription);
				exit(EXIT_FAILURE);
			}
			CLInfo(@"Fetching development teams...");
			[accountSession fetchTeams:^(NSArray<ALTTeam *> *teams, NSError *error) {
				if (error) {
					CLError(@"Fetching failed: %@", error.localizedDescription);
					exit(EXIT_FAILURE);
				}
				ALTTeam *team = [teams signer_first:^BOOL(ALTTeam *obj) {
					return obj.type == ALTTeamTypeFree;
				}];
				if (!team) {
					CLError(@"Can not found a team");
					exit(EXIT_FAILURE);
				}
				
				ALTAccount *account = accountSession.account;
				CLInfo(@"---------");
				CLInfo(@"Account: %@ (%@)", account.name, account.appleID);
				CLInfo(@"Team: %@ (%@)", team.name, team.identifier);
				CLInfo(@"---------");
				CLSuccess(@"Login succeed!");
				exit(EXIT_SUCCESS);
			}];
		}];
		[[NSRunLoop currentRunLoop] run];
		return EXIT_SUCCESS;
	}];
}

@end
