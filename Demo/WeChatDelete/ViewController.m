//
//  ViewController.m
//  WeChatDelete
//
//  Created by 乐升平 on 2018/12/10.
//  Copyright © 2018 乐升平. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *list;
@property (nonatomic, strong) UILabel *sureDeleteLabel; // 确认删除Label
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configDataSource];
    [self setupTableView];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // 获取系统左滑手势
    for (UIGestureRecognizer *ges in self.tableView.gestureRecognizers) {
        if ([ges isKindOfClass:NSClassFromString(@"_UISwipeActionPanGestureRecognizer")]) {
            [ges addTarget:self action:@selector(_swipeRecognizerDidRecognize:)];
        }
    }
}

- (void)_swipeRecognizerDidRecognize:(UISwipeGestureRecognizer *)swip {
    [_sureDeleteLabel removeFromSuperview];
    _sureDeleteLabel = nil;
    /*
    CGPoint currentPoint = [swip locationInView:self.tableView];
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        if (CGRectContainsPoint(cell.frame, currentPoint)) {
            if (cell.frame.origin.x > 0) {
                cell.frame = CGRectMake(0, cell.frame.origin.y,cell.bounds.size.width, cell.bounds.size.height);
            }
        }
    }
     */
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (nullable UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath  API_AVAILABLE(ios(11.0)){
    
    UIContextualAction *deleteRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:[NSString stringWithFormat:@"删除"] handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
        if (self.sureDeleteLabel.superview) { // 说明确认删除Label显示在界面上
            NSLog(@"确认删除");
        } else {
            NSLog(@"显示确认删除Label");
            // 核心代码
            UIView *rootView = nil; // 这个根view指的是UISwipeActionPullView，最上层的父view
            if ([sourceView isKindOfClass:[UILabel class]]) {
                rootView = sourceView.superview.superview;
                self.sureDeleteLabel.font = ((UILabel *)sourceView).font;
            }
            self.sureDeleteLabel.frame = CGRectMake(sourceView.bounds.size.width, 0, sourceView.bounds.size.width, sourceView.bounds.size.height);
            [sourceView.superview.superview addSubview:self.sureDeleteLabel];

            [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                CGRect labelFrame = self.sureDeleteLabel.frame;
                labelFrame.origin.x = 0;
                labelFrame.size.width = rootView.bounds.size.width;
                self.sureDeleteLabel.frame = labelFrame;
            } completion:^(BOOL finished) {
                
            }];
        }
    }];
    
    
    UIContextualAction *remarkAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"备注" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        // 如果确认删除Label显示在界面上，那么本次点击备注的区域响应确认删除按钮事件
        if(self.sureDeleteLabel.superview) {
            NSLog(@"确认删除");
        } else {
            NSLog(@"备注");
        }
    }];
    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteRowAction,remarkAction]];
    config.performsFirstActionWithFullSwipe = NO;
    
    return config;
}

- (nullable UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

//  在这个代理方法里，可以获取左滑按钮，进而修改其文字颜色，大小等
- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"将要开始编辑cell");
    
    for (UIView *subView in tableView.subviews) {
        if ([subView isKindOfClass:NSClassFromString(@"UISwipeActionPullView")]) {
            for (UIView *childView in subView.subviews) {
                if ([childView isKindOfClass:NSClassFromString(@"UISwipeActionStandardButton")]) {
                    UIButton *button = (UIButton *)childView;
                    button.titleLabel.font = [UIFont systemFontOfSize:18];
                }
            }
        }
    }
    
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"已经结束编辑cell");
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.list.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myCell"];
    }
    cell.textLabel.text = self.list[indexPath.row];
    [cell prepareForReuse];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UILabel *)sureDeleteLabel {
    if (!_sureDeleteLabel) {
        UILabel *sureDeleteLabel = [[UILabel alloc] init];
        sureDeleteLabel.text = @"确认删除";
        sureDeleteLabel.textAlignment = NSTextAlignmentCenter;
        sureDeleteLabel.textColor = [UIColor whiteColor];
        sureDeleteLabel.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:56.0/255.0 blue:50.0/255.0 alpha:1.0];
        sureDeleteLabel.userInteractionEnabled = YES;
        _sureDeleteLabel = sureDeleteLabel;
    }
    return _sureDeleteLabel;
}

- (void)configDataSource {
    self.list = [NSMutableArray arrayWithArray:@[@"🍎苹果苹果苹果苹果苹果",@"🍐梨梨梨梨梨",@"🍊橘子橘子橘子橘子橘子",@"🍌香蕉香蕉香蕉香蕉香蕉",@"🍓草莓草莓草莓草莓草莓",@"🍊橙子橙子橙子橙子橙子",@"🍅番茄番茄番茄番茄番茄",@"🍉西瓜西瓜西瓜西瓜西瓜",@"🍍菠萝菠萝菠萝菠萝菠萝",@"🥜花生花生花生花生花生",@"🍇葡萄葡萄葡萄葡萄葡萄",@"🌰栗子栗子栗子栗子栗子",@"🍑桃子桃子桃子桃子桃子",@"🍋柠檬柠檬柠檬柠檬柠檬",@"🥥椰子椰子椰子椰子椰子",@"🍒樱桃樱桃樱桃樱桃樱桃"]];
}

@end
