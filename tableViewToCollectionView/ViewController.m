//
//  ViewController.m
//  tableViewToCollectionView
//
//  Created by YouLoft_MacMini on 16/1/6.
//  Copyright © 2016年 wazrx. All rights reserved.
//

#import "ViewController.h"
#import "PushViewController.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) UITableView *mainView;
@property (nonatomic, strong) NSMutableArray *data;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITableView *mainView = [UITableView new];
    _mainView = mainView;
    mainView.frame = self.view.bounds;
    mainView.delegate = self;
    mainView.dataSource = self;
    mainView.rowHeight = 60;
//    [mainView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:mainView];
}

-(NSMutableArray *)data{
    if (!_data) {
        _data = @[].mutableCopy;
        for (int i = 1; i < 13; i ++) {
            [_data addObject:[NSString stringWithFormat:@"zrx%d.jpg", i]];
        }
        [_data addObjectsFromArray:_data];
        [_data addObjectsFromArray:_data];
    }
    return _data;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.imageView.hidden = NO;
    cell.imageView.image = [UIImage imageNamed:_data[indexPath.row]];
    cell.textLabel.text = _data[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PushViewController *pushVC = [PushViewController new];
    self.navigationController.delegate = pushVC;
    [self.navigationController pushViewController:pushVC animated:YES];
}

@end
