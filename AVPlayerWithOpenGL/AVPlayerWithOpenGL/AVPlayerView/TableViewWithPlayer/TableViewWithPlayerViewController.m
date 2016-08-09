//
//  TableViewWithPlayerViewController.m
//  AVPlayerWithOpenGL
//
//  Created by baidu on 16/8/5.
//  Copyright © 2016年 史瑞昌. All rights reserved.
//

#import "TableViewWithPlayerViewController.h"
#import "PlayerView.h"
#import <AVFoundation/AVFoundation.h>
@interface TableViewWithPlayerViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITableView *tableView;

@property(nonatomic,strong)PlayerView *playerView;
@property(nonatomic,strong)AVPlayerItem * playItem;
@property(nonatomic,strong)NSMutableArray *list;

@end

@implementation TableViewWithPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    [self.view addSubview:self.tableView];
    self.list=[NSMutableArray new];
}
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //随意
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TableSampleIdentifier = @"TableSampleIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             TableSampleIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:TableSampleIdentifier];
    }
    //声明一个播放器
    //测试视频播放  avplayer
    
    NSURL *url=[[NSURL alloc]initWithString:@"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"];
    PlayerView *tempPlayer =[[PlayerView alloc]initWithFillMode:@""];
    
    AVPlayerItem *tempItem =[[AVPlayerItem alloc]initWithURL:url];
    [tempPlayer.player replaceCurrentItemWithPlayerItem:tempItem];
    
    tempPlayer.frame=CGRectMake(0, 0,[[UIScreen mainScreen] bounds].size.width-10 , [[UIScreen mainScreen] bounds].size.height-64);
    tempPlayer.layer.frame=CGRectMake(0, -64,[[UIScreen mainScreen] bounds].size.width-10 , [[UIScreen mainScreen] bounds].size.height-64);
    
    [cell addSubview:tempPlayer];
    [self.list addObject:tempPlayer];
    cell.frame=CGRectMake(0, -64,[[UIScreen mainScreen] bounds].size.width-10 , [[UIScreen mainScreen] bounds].size.height-64);
    
    return cell;
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlayerView *tempView=[self.list objectAtIndex:indexPath.row];
    [tempView.player play];
    NSLog(@"点了\n");
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[UIScreen mainScreen] bounds].size.height-64;
}
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    PlayerView *tempView=[self.list objectAtIndex:indexPath.row];
    [tempView.player pause];
    NSLog(@"结束\n");
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
