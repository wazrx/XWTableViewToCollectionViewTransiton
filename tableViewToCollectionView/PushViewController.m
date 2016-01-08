//
//  PushViewController.m
//  tableViewToCollectionView
//
//  Created by YouLoft_MacMini on 16/1/6.
//  Copyright © 2016年 wazrx. All rights reserved.
//

#import "PushViewController.h"
#import "XWNaviTransition.h"
#import "XWInteractiveTransition.h"

@interface PushViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, weak) UICollectionView *mainView;
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) XWInteractiveTransition *interactiveTransition;
@end

@implementation PushViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = CGSizeMake(100, 100);
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 10;
    UICollectionView *mainView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    mainView.dataSource = self;
    mainView.delegate = self;
    mainView.backgroundColor = [UIColor whiteColor];
    _mainView = mainView;
    [mainView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self.view addSubview:mainView];
    //初始化手势过渡的代理
    self.interactiveTransition = [XWInteractiveTransition interactiveTransitionWithTransitionType:XWInteractiveTransitionTypePop GestureDirection:XWInteractiveTransitionGestureDirectionLeft];
    //给当前控制器的视图添加手势
    [_interactiveTransition addPanGestureForViewController:self];
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

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:_data[indexPath.item]]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC{
    //分pop和push两种情况分别返回动画过渡代理相应不同的动画操作
    XWNaviTransition *transition = [XWNaviTransition transitionWithType:operation == UINavigationControllerOperationPush ? XWNaviOneTransitionTypePush : XWNaviOneTransitionTypePop];
    transition.data = self.data;
    return transition;
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController{
    //手势开始的时候才需要传入手势过渡代理，如果直接点击pop，应该传入空，否者无法通过点击正常pop
    return _interactiveTransition.interation ? _interactiveTransition : nil;
}

@end
