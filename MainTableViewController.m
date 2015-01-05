//
//  MainTableViewController.m
//  MyCouponsTest
//
//  Created by Shady Gabal on 11/18/14.
//  Copyright (c) 2014 Shady Gabal. All rights reserved.
//

#import "MainTableViewController.h"
#import "CouponStore.h"
#import "LocationHandler.h"

/* FEATURES:
 1) Displays all coupons near you sorted by distance and popularity pulled from online database
 2) Tells you when you pass by a store if it has a coupon available (push notification). does this maybe once or twice a day so as to not annoy user to turn it off - also make it seem like a 'Hot' and 'popular' coupon. Lastly, don't allow this for cheap coupons
 3) Tracks how many times a user visits a merchant and when his last visit to the merchant was
 4) Allows users to redeem a coupon by clicking 'use'
 5) 
 
 Problems:
 1) Only pulling coupons near someone - send in JSON request lat and long coordinates
 2) Constantly check if coordinates user is at have a merchant near them with a popular coupon
 
 */

static float PADDING_BETWEEN_CELL_BORDER_AND_IMAGE_VIEW = 3.f;
static NSString * SERVER_DOMAIN = @"http://localhost:3000/";


@interface MainTableViewController ()

@end

typedef enum : NSUInteger {
    TAG_TYPE_IMAGE_VIEW = 1,
    TAG_TYPE_READ_MORE_VIEW = 2

} COUPON_VIEW_TAG_TYPES;

@implementation MainTableViewController{
    CouponStore * _couponStore;
    
    /* for readmore view */
    BOOL _isReadMoreSelected;
    long _readMoreIndex;
    Coupon * _currSelectedCoupon;
    
    /* for location */
    LocationHandler * _locationHandler;
    
    /* colors */
    UIColor * _cellColor;
    UIColor * _tableColor;
}

-(void) alertWithTitle:(NSString *)title message:(NSString *) message{
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

-(id) init{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self){
        //setup location
        _locationHandler = [LocationHandler sharedInstance];
        if (!_locationHandler){
            NSLog(@"Error: You must have location services enabled in order to use this app.");
            //do stuff that prevents user from using app
        }
        else{
            _locationHandler.mainViewController = self;
            [_locationHandler startTrackingLocation];
        }
        
        //setup table look
//        _cellColor = [UIColor colorWithRed:(211.f/255.f) green:(211.f/255.f) blue:(211.f/255.f) alpha:1.f];
        
//        UIImageView * backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"wood_background.jpg"]];
//        backgroundView.frame = self.tableView.frame;
//        self.tableView.backgroundView = backgroundView;
       
        _cellColor = [UIColor clearColor];
        
        _tableColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"wood_background.jpg"]];
        self.tableView.backgroundColor = _tableColor;

        //create coupon store
        _couponStore = [CouponStore sharedInstance];
        
        //setup readmore values
        _readMoreIndex = -1;
        _isReadMoreSelected = NO;
        
        
        
    }
    return self;
}

-(void) setup{
    //get coupons from server
    [_couponStore getCouponsFromServer];
    for (int i = 0; i < 3; i++){
        Coupon * createdCoupon = [_couponStore createCoupon];
        //            NSLog(@"%@", createdCoupon);
    }
    for (int i = 0; i < 3; i++){
        [_couponStore createCouponFromTemplateNum:1];
    }
    for (int i = 0; i < 3; i++){
        Coupon * createdCoupon = [_couponStore createCoupon];
        //            NSLog(@"%@", createdCoupon);
    }
    for (int i = 0; i < 3; i++){
        [_couponStore createCouponFromTemplateNum:1];
    }
    [self.tableView reloadData];
}

-(BOOL) usingLocation{
    _usingLocation = ![_locationHandler deniedLocationAccess];
    return _usingLocation;
}

-(void) userDeniedLocation{
    NSLog(@"yo %d", _locationHandler.deniedLocationAccess);
    if (_locationHandler.deniedLocationAccess && !self.didShowLocationDeniedPopup){
        self.didShowLocationDeniedPopup = YES;
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Cannot use app" message:@"We need your location in order to find the coupons closest to you. Without it, this app will not work." delegate:self cancelButtonTitle:@"Fix" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: UIApplicationOpenSettingsURLString]];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Coupon"];
    self.tableView.separatorColor = [UIColor clearColor];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(long) correctCouponIndexForIndexPath:(NSIndexPath *) indexPath{
    if (indexPath.row > _readMoreIndex && _isReadMoreSelected)
        return indexPath.row - 1;
    else return indexPath.row;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (_isReadMoreSelected)
        return [[_couponStore allCoupons] count] + 1;
    else return [[_couponStore allCoupons] count];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //check if index of cell at this index path is a readmore box
    //if it is, return the standard height of a coupon read more box
    //else return the height of the coupon image view frame
    
    if (indexPath.row == _readMoreIndex && _isReadMoreSelected){
        Coupon * coupon = [_couponStore allCoupons][indexPath.row - 1];
        NSLog(@"height for readmoreview at index %ld is %f", indexPath.row, coupon.couponReadMoreView.frame.size.height);
        return coupon.couponReadMoreView.frame.size.height;
    }
    else{
        long correctCouponIndex = [self correctCouponIndexForIndexPath:indexPath];
        Coupon * coupon = [_couponStore allCoupons][correctCouponIndex];
        NSLog(@"height for row at index %ld is %f", (long)indexPath.row, coupon.couponImageView.frame.size.height + PADDING_BETWEEN_CELL_BORDER_AND_IMAGE_VIEW);
        return coupon.couponImageView.frame.size.height + PADDING_BETWEEN_CELL_BORDER_AND_IMAGE_VIEW;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //get cell to reuse
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Coupon" forIndexPath:indexPath];
    
    //style cell
    cell.backgroundColor = _cellColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    /* clean cell before using */
    UIView * oldImageView = [cell.contentView viewWithTag:TAG_TYPE_IMAGE_VIEW];
//    oldImageView.center = CGPointMake(0,0);
    [oldImageView removeFromSuperview];
    [[cell.contentView viewWithTag:TAG_TYPE_READ_MORE_VIEW]removeFromSuperview];


    /* if the path of the cell that is to be displayed is a readmore view */
    if (_isReadMoreSelected && indexPath.row == _readMoreIndex){
        /* get correct coupon */
        Coupon * coupon = [_couponStore allCoupons][indexPath.row - 1];
        /* add readmore view */
        coupon.couponReadMoreView.center = CGPointMake(cell.contentView.bounds.size.width/2,cell.contentView.bounds.size.height/2);
        [cell.contentView addSubview:coupon.couponReadMoreView];

        coupon.couponReadMoreView.tag = TAG_TYPE_READ_MORE_VIEW;
        }
    
    /* else you're displaying a coupon */
    else{
        /* get correct index of the coupon in the couponstore array */
        long correctCouponIndex = [self correctCouponIndexForIndexPath:indexPath];
        Coupon * coupon = [_couponStore allCoupons][correctCouponIndex];
        
        /* add coupon imageview */
        coupon.couponImageView.tag = TAG_TYPE_IMAGE_VIEW;
        coupon.couponImageView.center = CGPointMake(cell.contentView.bounds.size.width/2,cell.contentView.bounds.size.height/2 + PADDING_BETWEEN_CELL_BORDER_AND_IMAGE_VIEW);
        [cell.contentView addSubview:coupon.couponImageView];
        //****** add uitableviewcell extension to enable a coupon property (?)
    }
    return cell;
}


- (void)listSubviewsOfView:(UIView *)view {
    
    // Get the subviews of the view
    NSArray *subviews = [view subviews];
    
    // Return if there are no subviews
    if ([subviews count] == 0) return; // COUNT CHECK LINE
    
    for (UIView *subview in subviews) {
        
        // Do what you want to do with the subview
        NSLog(@"%@", subview);
        
        // List the subviews of subview
        [self listSubviewsOfView:subview];
    }
    NSLog(@"-------------");
}

-(void) removeReadMoreView{
    //first set _isReadMoreSelected to false so that when deleting rows the table cell count is adjusted
    _isReadMoreSelected = NO;

    NSIndexPath * path = [NSIndexPath indexPathForRow:_readMoreIndex inSection:0];
    UITableViewCell * readMoreCell = [self.tableView cellForRowAtIndexPath:path];
    [[readMoreCell.contentView viewWithTag:TAG_TYPE_READ_MORE_VIEW]removeFromSuperview];
    [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationTop];
    _currSelectedCoupon.selected = NO;
    _currSelectedCoupon = nil;
    _readMoreIndex = -1;
    
}

-(void) insertReadMoreViewForCoupon:(Coupon *) coupon atIndexPath:(NSIndexPath *) indexPath{
    NSLog(@"inserting readmoreview for coupon at index path: %ld", (long)indexPath.row);
    _currSelectedCoupon = coupon;
    _currSelectedCoupon.selected = YES;
    
    _readMoreIndex = indexPath.row + 1;
    _isReadMoreSelected = YES;
    NSIndexPath * path = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"touched coupon at index path: %ld", (long)indexPath.row);
//    
//    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
//    cell.backgroundColor = [UIColor blackColor];
    
    if (indexPath.row != _readMoreIndex || ! _isReadMoreSelected){
        long correctCouponIndex = [self correctCouponIndexForIndexPath:indexPath];
        Coupon * coupon = [_couponStore allCoupons][correctCouponIndex];
        
        /* if coupon is already selected, remove it's read more box and update the readmoreindeces array */
        if (coupon.selected){
            NSLog(@"coupon deselected");
            [self removeReadMoreView];
        }
        
        //if the coupon is not already selected, add it's read more box in the next cell and update the readmoreindeces array
        else{
            
            if (_isReadMoreSelected){
                if (_readMoreIndex < indexPath.row)
                    indexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
                [self removeReadMoreView];

            }
            
            NSLog(@"coupon selected");
            [self insertReadMoreViewForCoupon:coupon atIndexPath:indexPath];
        }
    }

}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
