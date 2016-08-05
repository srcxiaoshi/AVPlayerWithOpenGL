//
//  TableWithPlayerViewController.m
//  AVPlayerWithOpenGL
//
//  Created by baidu on 16/8/5.
//  Copyright © 2016年 史瑞昌. All rights reserved.
//

#import "TableWithPlayerViewController.h"
#import "PlayerView.h"
#import <AVFoundation/AVFoundation.h>



@interface TableWithPlayerViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)UITableView *tableView;

@property(nonatomic,strong)PlayerView *playerView;
@property(nonatomic,strong)AVPlayerItem * playItem;



@end

@implementation TableWithPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor whiteColor];
    
    self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.view addSubview:self.tableView];
    
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
    //定制cell
    cell.frame=CGRectMake(0,64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64);
    cell.backgroundColor=[UIColor blueColor];
    NSURL *url=[[NSURL alloc]initWithString:@"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"];
    self.playerView=[[PlayerView alloc]initWithFillMode:@""];
    self.playItem=[[AVPlayerItem alloc]initWithURL:url];
    [self.playerView.player replaceCurrentItemWithPlayerItem:_playItem];
    self.playerView.layer.frame=CGRectMake(0, 100, 180, 100);
    [cell addSubview:self.playerView];
    

    return cell;
}

#pragma mark  UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.playerView.player play];
    NSLog(@"点了\n");
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
