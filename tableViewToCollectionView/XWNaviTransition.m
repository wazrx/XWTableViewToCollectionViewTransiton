
//
//  XWNaviOneTransition.m
//  trasitionpractice
//
//  Created by YouLoft_MacMini on 15/11/23.
//  Copyright © 2015年 YouLoft_MacMini. All rights reserved.
//

#import "XWNaviTransition.h"

@interface XWNaviTransition ()
/**
 *  动画过渡代理管理的是push还是pop
 */
@property (nonatomic, assign) XWNaviOneTransitionType type;
@property (nonatomic, strong) NSMutableArray *imageViews;

@end

@implementation XWNaviTransition

+ (instancetype)transitionWithType:(XWNaviOneTransitionType)type{
    return [[self alloc] initWithTransitionType:type];
}

- (instancetype)initWithTransitionType:(XWNaviOneTransitionType)type{
    self = [super init];
    if (self) {
        _type = type;
    }
    return self;
}
/**
 *  动画时长
 */
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.75;
}
/**
 *  如何执行过渡动画
 */
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    switch (_type) {
        case XWNaviOneTransitionTypePush:
            [self doPushAnimation:transitionContext];
            break;
            
        case XWNaviOneTransitionTypePop:
            [self doPopAnimation:transitionContext];
            break;
    }
    
}

/**
 *  执行push过渡动画
 */
- (void)doPushAnimation:(id<UIViewControllerContextTransitioning>)transitionContext{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    UITableView *tableView = fromVC.view.subviews.lastObject;
    UICollectionView *collectionView = toVC.view.subviews.lastObject;
    [containerView addSubview:toVC.view];
    toVC.view.alpha = 0;
    collectionView.hidden = YES;
    //得到当前tableView显示在屏幕上的indexPath
    NSArray *visibleIndexpaths = [tableView indexPathsForVisibleRows];
    //拿到tableView可显示的第一个indexPath
    NSIndexPath *tableViewFirstPath = visibleIndexpaths.firstObject;
    //拿到tableView可显示的最后一个indexPath
    NSIndexPath *tableViewLastPath = visibleIndexpaths.lastObject;
    //得到tableView可显示的第一个cell
    UITableViewCell *firstVisibleCell = [tableView cellForRowAtIndexPath:tableViewFirstPath];
    //得到当前点击的indexPath
    NSIndexPath *selectIndexPath = [tableView indexPathForSelectedRow];
    //通过点击的indexPath和collectionView的ContentSize计算collectionView显示时候的contentOffset
    //获取点击indexPath对应在collectionView中的attr
    UICollectionViewLayoutAttributes *selectAttr = [collectionView layoutAttributesForItemAtIndexPath:selectIndexPath];
    //获取collectionView的ContentSize
    CGSize contentSize = [collectionView.collectionViewLayout collectionViewContentSize];
    //计算contentOffset的最大值
    CGFloat maxY = contentSize.height - collectionView.bounds.size.height;
    //计算collectionView显示时候的offset：如果该offset超过了最大值就去最大值，否则就取将所选择的indexPath的item排在可显示的第一行的时候的indexPath
    CGPoint newOffset = CGPointMake(0, MIN(maxY, selectAttr.frame.origin.y - 64));
    //得到当前显示区域的frame
    CGRect newFrame = CGRectMake(0, MIN(maxY, selectAttr.frame.origin.y), collectionView.bounds.size.width, collectionView.bounds.size.height);
    //根据frame得到可显示区域内所有的item的attrs
    NSArray *showAttrs = [collectionView.collectionViewLayout layoutAttributesForElementsInRect:newFrame];
    //进而得到所有可显示的item的indexPath
    NSMutableArray *showIndexPaths = @[].mutableCopy;
    for (UICollectionViewLayoutAttributes *attr in showAttrs) {
        [showIndexPaths addObject:attr.indexPath];
    }
    //拿到collectionView可显示的第一个indexPath
    NSIndexPath *collectionViewFirstPath = showIndexPaths.firstObject;
    //拿到collectionView可显示的最后一个indexPath
    NSIndexPath *collectionViewLastPath = showIndexPaths.lastObject;
    //现在可以拿到需要动画的第一个indexpath
    NSIndexPath *animationFirstIndexPath = collectionViewFirstPath.item > tableViewFirstPath.row ? tableViewFirstPath : collectionViewFirstPath;
    //现在可以拿到需要动画的最后一个indexpath
    NSIndexPath *animationLastIndexPath = collectionViewLastPath.item > tableViewLastPath.row ? collectionViewLastPath : tableViewLastPath;
    //下面就可以计算需要动画的视图的起始frame了
    NSMutableArray *animationViews = @[].mutableCopy;
    NSMutableArray *animationIndexPaths = @[].mutableCopy;
    NSMutableArray *images = @[].mutableCopy;
    for (NSInteger i = animationFirstIndexPath.row; i <= animationLastIndexPath.row; i ++) {
        //这里就无法使用截图大法了，因为我们要计算可显示区域外的cell的位置，所以只有直接通过数据源取得图片，自己生成ImageView
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:_data[i]]];
        //frame从第一个开始依次向下排列
        imageView.frame = CGRectApplyAffineTransform([[firstVisibleCell imageView] convertRect:[firstVisibleCell imageView].bounds toView:containerView], CGAffineTransformMakeTranslation(0, - tableView.rowHeight * (tableViewFirstPath.row - i)));
        //添加imageView到contentView
        [animationViews addObject:imageView];
        [containerView addSubview:imageView];
        [animationIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        //隐藏tableView的imageView
        UIImageView *imgView = (UIImageView *)[[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]] imageView];
        if (imgView) {
            imgView.hidden = YES;
            [images addObject:imgView];
        }
    }
    //终于可以动画了
    [UIView animateWithDuration:1 animations:^{
        //让toView显示出来
        toVC.view.alpha = 1;
        //取出所有的可动画的imageView，并移动到对应collectionView的正确位置去
        for (int i = 0; i < animationViews.count; i ++) {
            UIView *animationView = animationViews[i];
            NSIndexPath *animationPath = animationIndexPaths[i];
            animationView.frame = CGRectApplyAffineTransform([collectionView layoutAttributesForItemAtIndexPath:animationPath].frame, CGAffineTransformMakeTranslation(0, -newOffset.y));
        }
    } completion:^(BOOL finished) {
        //设置collectionView的contentOffset
        [collectionView setContentOffset:newOffset];
        //移除所有的可动画视图
        [animationViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        //显示出collectionView
        collectionView.hidden = NO;
        //标记转场完成
        [transitionContext completeTransition:YES];
        
        for (int i = 0; i < _data.count; i ++) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            cell.imageView.hidden = NO;
        }
    }];
}
/**
 *  执行pop过渡动画
 */
- (void)doPopAnimation:(id<UIViewControllerContextTransitioning>)transitionContext{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    UITableView *tableView = toVC.view.subviews.lastObject;
    UICollectionView *collectionView = fromVC.view.subviews.lastObject;
    [containerView addSubview:toVC.view];
    toVC.view.alpha = 0;
    //collectionView可显示的所有cell
    NSArray *visibleCells = [collectionView visibleCells];
    //collectionView可显示的所有indexPath
    NSMutableArray *collectionViewVisbleIndexPaths = @[].mutableCopy;
    for (UICollectionViewCell *cell in visibleCells) {
        [collectionViewVisbleIndexPaths addObject:[collectionView indexPathForCell:cell]];
        cell.hidden = YES;
        
    }
    //由于取出的顺序不是从小到大，所以排序一次
    [collectionViewVisbleIndexPaths sortUsingComparator:^NSComparisonResult(NSIndexPath * obj1, NSIndexPath * obj2) {
        return obj1.item < obj2.item ? NSOrderedAscending : NSOrderedDescending;
    }];
    //当前选中的cell
    NSIndexPath *selectIndexPath = [collectionView indexPathsForSelectedItems].firstObject;
    //如果不存在，比如直接back，取可显示的第一个cell
    if (!selectIndexPath) {
        selectIndexPath = collectionViewVisbleIndexPaths.firstObject;
    }
    //计算tableView最大的contentOffsetY
    CGFloat maxY = tableView.contentSize.height - tableView.frame.size.height;
    //根据点击的selectIndexPath和maxY得到当前tableView应该移动到的offset
    CGPoint newOffset = CGPointMake(0, MIN(maxY, tableView.rowHeight * selectIndexPath.item - 64));
    
    //设置tableView的newOffset,必须先设置，下面的操作都建于此设置之后
    [tableView setContentOffset:newOffset];
    //取出newOffset下的可显示cell,隐藏cell的imageView
    NSMutableArray *tableViewVisibleIndexPaths = @[].mutableCopy;
    for (UITableViewCell *cell in [tableView visibleCells]) {
        cell.imageView.hidden = YES;
        [tableViewVisibleIndexPaths addObject:[tableView indexPathForCell:cell]];
    }
    //计算可动画的第一个indexPath
    NSIndexPath *animationFirstIndexPath = [tableViewVisibleIndexPaths.firstObject row] > [collectionViewVisbleIndexPaths.firstObject row] ? collectionViewVisbleIndexPaths.firstObject : tableViewVisibleIndexPaths.firstObject;
    //计算可动画的最后一个indexPath
    NSIndexPath *animationLastIndexPath = [tableViewVisibleIndexPaths.lastObject row] > [collectionViewVisbleIndexPaths.lastObject row] ? tableViewVisibleIndexPaths.lastObject : collectionViewVisbleIndexPaths.lastObject;
    //生成所有需要动画的临时UIImageView存在一个临时数组
    NSMutableArray *animationViews = @[].mutableCopy;
    NSMutableArray *animationIndexPaths = @[].mutableCopy;
    for (NSInteger i = animationFirstIndexPath.row; i <= animationLastIndexPath.row; i ++) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:_data[i]]];
        //frame为当前对应的item减去offset的值
        imageView.frame = CGRectApplyAffineTransform([collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]].frame, CGAffineTransformMakeTranslation(0,  -collectionView.contentOffset.y));
        [containerView addSubview:imageView];
        [animationViews addObject:imageView];
        [animationIndexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
    }
    //开始动画
    [UIView animateWithDuration:1 animations:^{
        //显示出toView
        toVC.view.alpha = 1;
        //取出所有的动画视图设置其动画结束的frame，frame有indexPath和newOffset决定
        for (int i = 0; i < animationViews.count; i ++) {
            UIView *animationView = animationViews[i];
            NSIndexPath *animationPath = animationIndexPaths[i];
            animationView.frame = CGRectMake(15, tableView.rowHeight * [animationPath row]  - newOffset.y, tableView.rowHeight, tableView.rowHeight);
        }
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        if (![transitionContext transitionWasCancelled]) {
            //如果成功了
            //显示visiblecell中的imageView
            for (UITableViewCell *cell in [tableView visibleCells]) {
                cell.imageView.hidden = NO;
            }
        }else{
            //否者显示出隐藏的collectionView的item
            for (UICollectionViewCell *cell in visibleCells) {
                [collectionViewVisbleIndexPaths addObject:[collectionView indexPathForCell:cell]];
                cell.hidden = NO;
            }
        }
        //移除所有的临时视图
        [animationViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }];
}

@end
