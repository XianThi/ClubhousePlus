#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <Security/Security.h>

@interface ClubhousePlus : NSObject
+(void)customAlert:(NSString *)msg sender:(UIViewController*)sender;
+(void)log2file:(NSString *)textToWrite;
@end


@interface SServerUser:NSObject
@property (nonatomic,readwrite,strong) NSNumber *userId;
@property (nonatomic,readwrite,strong) NSString *name;
@property (nonatomic,readwrite,strong) NSString *photoUrl;
@property (nonatomic,readwrite,strong) NSString *username;
@end

@interface SServerUserInList:SServerUser
@property (nonatomic,readwrite,strong) NSString *bio;
@property (nonatomic,readwrite,strong) NSString *twitter;
@property (nonatomic,readwrite,strong) NSNumber *lastActiveMinutes;
@property (nonatomic,readwrite,strong) NSDictionary *loginContext;
@end


@interface FollowersViewCell:UITableViewCell
@property (nonatomic,readwrite,strong) UIButton *addButton;
@property (nonatomic,readwrite,strong) SServerUserInList *user;
@end


@interface FollowersTableController<UITableViewDelegate>:NSObject
@property (nonatomic,readwrite,strong) NSArray *users;
@property (nonatomic,readwrite,strong) NSArray *clubs;
-(void)tableView:(id)tableView willDisplayCell:(FollowersViewCell*)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
@end


@interface FollowersViewController:UIViewController
@property (nonatomic,readwrite,strong) UIView *viewIfLoaded;
@property (nonatomic,readwrite,strong) NSNumber *userId;
@property (nonatomic,readwrite,strong) UITableView *tableView;
@property (nonatomic,readwrite,strong) NSString *username;
-(void)unfollowbuttonclick;
@end