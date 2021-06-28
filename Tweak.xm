#import "ClubhousePlus.h"
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define alertsender [[[[UIApplication sharedApplication]delegate] window] rootViewController]

@implementation ClubhousePlus
+(void)customAlert:(NSString *)msg sender:(UIViewController*)sender{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"ClubhousePlus" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * actionOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];

    [alert addAction:actionOK];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"12.4")) {
        [sender presentViewController:alert animated:YES completion:nil];
    }

    else{
        [[[UIApplication sharedApplication].delegate window].rootViewController presentViewController:alert animated:YES completion:nil];
    }

}

@end

static NSNumber *rowCount;
static NSArray *followers;
static NSMutableArray *not_following;
static bool followers_screen = false;
static NSMutableDictionary  *unfollow_btns;

%hook FollowersTableController
-(void)updateDataWithClubs:(id)clublist users:(NSArray *)userlist{
	%orig;
	if(followers_screen){
		followers = [userlist copy];
	}
}

%new
-(void)tableView:(id)tableView willDisplayCell:(FollowersViewCell*)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
	//[ClubhousePlus customAlert:NSStringFromClass([cell class]) sender:alertsender];
	if (class_getProperty([cell class], "addButton")) {
		[unfollow_btns setObject:cell.addButton forKey:[cell.user.userId stringValue]];
	}
}
%end



%hook FollowersViewController



-(void)viewDidLoad{
	%orig;
	//[ClubhousePlus customAlert:@"test" sender:self];
	if([self.title isEqual:@"FOLLOWERS"]){
		followers_screen = true;
	}else{
		followers_screen = false;
		UIButton* button = [UIButton buttonWithType: UIButtonTypeRoundedRect];
		button.frame = CGRectMake(265.0, 60.0, 100.0, 25.0);
		button.backgroundColor=[UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0];
		button.layer.cornerRadius = 10;
		button.clipsToBounds = true;
		[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[button setTitle:[NSString stringWithFormat:@"Unfollow"] forState:UIControlStateNormal];
		[button addTarget:self action:@selector(unfollowbuttonclick) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:button];
		unfollow_btns = [[NSMutableDictionary alloc] init]; 
	}
}

%new
-(void)unfollowbuttonclick{
	NSDictionary *kCachedFollowing = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"kCachedFollowing"];
	not_following = [[NSMutableArray alloc] init];
	NSMutableArray *followers_ex = [[NSMutableArray alloc] init];
	int i;
	//[ClubhousePlus customAlert:[NSString stringWithFormat:@"my dictionary is %@", kCachedFollowing] sender:alertsender];
	for (i = 0; i < [followers count]; i++) {
		[followers_ex addObject:[((SServerUserInList *)followers[i]).userId stringValue]];
	}
	
	for(NSString *userId in kCachedFollowing){
		if(![followers_ex containsObject:userId]){
			[not_following addObject:userId];
		}
	}
	int j;
	for (j = 0; j < [not_following count]; j++) {
		UIButton *btn = [unfollow_btns objectForKey:not_following[j]];
		//[ClubhousePlus customAlert:btn.titleLabel.text sender:alertsender];
		[btn sendActionsForControlEvents:UIControlEventTouchUpInside];
		[NSThread sleepForTimeInterval:0.5f];
	}
	[unfollow_btns removeAllObjects];
	[not_following removeAllObjects];
	[ClubhousePlus customAlert:@"Unfollowing all people who doesnt follow you. You need to scroll your screen every tapped." sender:alertsender];
	/*
	UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    indicator.center = self.view.center;
    [self.view addSubview:indicator];
    [indicator bringSubviewToFront:self.view];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    [indicator startAnimating];
	//[ClubhousePlus customAlert:[NSString stringWithFormat:@"%lu",[unfollow_btns count]] sender:alertsender];
	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
		int j;
		for (j = 0; j < [not_following count]; j++) {
			UIButton *btn = [unfollow_btns objectForKey:not_following[j]];
			//[ClubhousePlus customAlert:btn.titleLabel.text sender:alertsender];
			[btn sendActionsForControlEvents:UIControlEventTouchUpInside];
			[NSThread sleepForTimeInterval:0.5f];
		}
		dispatch_async(dispatch_get_main_queue(), ^(void){
			[indicator stopAnimating];
			[unfollow_btns removeAllObjects];
			[not_following removeAllObjects];
			[ClubhousePlus customAlert:@"Unfollowing all people who doesnt follow you. You need to scroll your screen every tapped." sender:alertsender];
		});
    }); */
}

%end

%ctor{
	%init(FollowersTableController = objc_getClass("clubhouse.FollowersTableController"));
}