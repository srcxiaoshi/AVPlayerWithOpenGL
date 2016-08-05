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

@end

@implementation TableViewWithPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    [self.view addSubview:self.tableView];
}
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //随意
    return 0;
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
    
    //NSURL *url=[[NSURL alloc]initWithString:@"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"];
    //self.playerView=[[PlayerView alloc]initWithFillMode:@""];
    //self.playerView.frame=CGRectMake(0, 0,[[UIScreen mainScreen] bounds].size.width-10 , [[UIScreen mainScreen] bounds].size.height);
    //self.playItem=[[AVPlayerItem alloc]initWithURL:url];
    //[self.playerView.player replaceCurrentItemWithPlayerItem:_playItem];
    //self.playerView.layer.frame=CGRectMake(0, 0,[[UIScreen mainScreen] bounds].size.width-10 , [[UIScreen mainScreen] bounds].size.height);
    //[cell addSubview:self.playerView];
    //[self.playerView.player play];
    //cell.frame=CGRectMake(0, 0,[[UIScreen mainScreen] bounds].size.width-10 , [[UIScreen mainScreen] bounds].size.height);
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    view.backgroundColor=[UIColor redColor];
    [cell addSubview:view];
    return cell;
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"点了\n");
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[UIScreen mainScreen] bounds].size.height;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
