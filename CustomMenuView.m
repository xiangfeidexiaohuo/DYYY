#import "CustomMenuView.h"
#import "CustomToastView.h"
#import <objc/runtime.h>

@implementation CustomMenuWindow

static CustomMenuWindow *sharedInstance = nil;

- (instancetype)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self) {

        self.windowLevel = UIWindowLevelStatusBar + 1;
        self.hidden = NO;
        [self makeKeyAndVisible]; 
        
        _menuView = [[CustomMenuView alloc] init];
        _menuView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        [self addSubview:_menuView];
        
        sharedInstance = self;

        if (@available(iOS 13.0, *)) {
            NSSet *connectedScenes = [UIApplication sharedApplication].connectedScenes;
            for (UIScene *scene in connectedScenes) {
                if ([scene isKindOfClass:[UIWindowScene class]]) {
                    self.windowScene = (UIWindowScene *)scene;
                    break;
                }
            }
        }
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGPoint pointInMenuView = [self convertPoint:point toView:self.menuView];
    return [self.menuView pointInside:pointInMenuView withEvent:event] ? [super hitTest:point withEvent:event] : nil;
}

@end

@implementation CustomMenuView {

    NSMutableSet *_expandedSections;  
}

#pragma mark - 初始化与配置

- (instancetype)init {
    self = [super init];
    if (self) {
        _expandedSections = [NSMutableSet set];
        [self initializeMenuData];
        [self configureUI];
    }
    return self;
}

- (void)initializeMenuData {
    _menuData = @[
    @{
        @"title" : @"基本设置",
        @"expanded" : @NO,
        @"items" : @[
            @{@"name" : @"启用弹幕改色", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYEnableDanmuColor"},
            @{@"name" : @"设置弹幕颜色", @"type" : @(DYYYSettingItemTypeTextField), @"key" : @"DYYYdanmuColor", @"placeholder" : @"十六进制"},
            @{@"name" : @"启用深色键盘", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYisDarkKeyBoard"},
            @{@"name" : @"启用视频进度", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYisShowSchedule"},
            @{@"name" : @"启用自动播放", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYisEnableAutoPlay"},
            @{@"name" : @"启用过滤直播", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYisSkipLive"},
            @{@"name" : @"启用首页净化", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYisEnablePure"},
            @{@"name" : @"启用首页全屏", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYisEnableFullScreen"},
            @{@"name" : @"评论区毛玻璃", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYisEnableCommentBlur"},
            @{@"name" : @"时间属地显示", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYisEnableArea"},
            @{@"name" : @"时间标签颜色", @"type" : @(DYYYSettingItemTypeTextField), @"key" : @"DYYYLabelColor", @"placeholder" : @"十六进制"},
            @{@"name" : @"隐藏系统顶栏", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYisHideStatusbar"},
            @{@"name" : @"关注二次确认", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYfollowTips"},
            @{@"name" : @"收藏二次确认", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYcollectTips"}
        ]
    },
    @{
        @"title" : @"界面设置",
        @"expanded" : @NO,
        @"items" : @[
            @{@"name" : @"设置顶栏透明", @"type" : @(DYYYSettingItemTypeTextField), @"key" : @"DYYYtopbartransparent", @"placeholder" : @"0-1小数"},
            @{@"name" : @"设置全局透明", @"type" : @(DYYYSettingItemTypeTextField), @"key" : @"DYYYGlobalTransparency", @"placeholder" : @"0-1的小数"},
            @{@"name" : @"设置默认倍速", @"type" : @(DYYYSettingItemTypeSpeedPicker), @"key" : @"DYYYElementScale"},
            @{@"name" : @"右侧栏缩放度", @"type" : @(DYYYSettingItemTypeTextField), @"key" : @"DYYYElementScale", @"placeholder" : @"不填默认"},
            @{@"name" : @"设置首页标题", @"type" : @(DYYYSettingItemTypeTextField), @"key" : @"DYYYIndexTitle", @"placeholder" : @"不填默认"},
            @{@"name" : @"设置朋友标题", @"type" : @(DYYYSettingItemTypeTextField), @"key" : @"DYYYFriendsTitle", @"placeholder" : @"不填默认"},
            @{@"name" : @"设置消息标题", @"type" : @(DYYYSettingItemTypeTextField), @"key" : @"DYYYMsgTitle", @"placeholder" : @"不填默认"},
            @{@"name" : @"设置我的标题", @"type" : @(DYYYSettingItemTypeTextField), @"key" : @"DYYYSelfTitle", @"placeholder" : @"不填默认"}
        ]
    },
    @{
        @"title" : @"隐藏设置",
        @"expanded" : @NO,
        @"items" : @[
            @{@"name" : @"隐藏全屏观看", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYisHiddenEntry"},
            @{@"name" : @"隐藏底栏商城", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYHideShopButton"},
            @{@"name" : @"隐藏底栏信息", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYHideMessageButton"},
            @{@"name" : @"隐藏底栏朋友", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYHideFriendsButton"},
            @{@"name" : @"隐藏底栏加号", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYisHiddenJia"},
            @{@"name" : @"隐藏底栏红点", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYisHiddenBottomDot"},
            @{@"name" : @"隐藏底栏背景", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYisHiddenBottomBg"},
            @{@"name" : @"隐藏侧栏红点", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYisHiddenSidebarDot"},
            @{@"name" : @"隐藏点赞按钮", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYHideLikeButton"},
            @{@"name" : @"隐藏评论按钮", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYHideCommentButton"},
            @{@"name" : @"隐藏收藏按钮", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYHideCollectButton"},
            @{@"name" : @"隐藏头像按钮", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYHideAvatarButton"},
            @{@"name" : @"隐藏音乐按钮", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYHideMusicButton"},
            @{@"name" : @"隐藏分享按钮", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYHideShareButton"},            
            @{@"name" : @"隐藏视频定位", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYHideLocation"},
            @{@"name" : @"隐藏右上搜索", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYHideDiscover"},
            @{@"name" : @"隐藏我的页面", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYHideMyPage"},
            @{@"name" : @"隐藏相关搜索", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYHideInteractionSearch"},
            @{@"name" : @"隐藏去汽水听", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYHideQuqishuiting"},
            @{@"name" : @"隐藏热点提示", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYHideHotspot"}
        ]
    },
    @{
        @"title" : @"顶栏移除",
        @"expanded" : @NO,
        @"items" : @[
            @{@"name" : @"移除推荐", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYHideHotContainer"},
            @{@"name" : @"移除关注", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYHideFollow"},
            @{@"name" : @"移除精选", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYHideMediumVideo"},
            @{@"name" : @"移除商城", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYHideMall"},
            @{@"name" : @"移除同城", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYHideNearby"},
            @{@"name" : @"移除团购", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYHideGroupon"},
            @{@"name" : @"移除直播", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYHideTabLive"},
            @{@"name" : @"移除热点", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYHidePadHot"},
            @{@"name" : @"移除经验", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYHideHangout"}
        ]
    },
    @{
        @"title" : @"其他功能",
        @"expanded" : @NO,
        @"items" : @[
            @{@"name" : @"复制文案", @"type" : @(DYYYSettingItemTypeSwitch), @"key" : @"DYYYCopyText"}
        ]
    }
];
    _expandedSections = [NSMutableSet set];  
    for (NSUInteger i = 0; i < _menuData.count; i++) {
        if ([_menuData[i][@"expanded"] boolValue]) {
            [_expandedSections addObject:@(i)];
        }
    }
}

- (void)configureUI {
    CGFloat menuWidth = UIScreen.mainScreen.bounds.size.width * 0.81;
    CGFloat headerHeight = 110;
    CGFloat rowHeight = 45.5;
    CGFloat maxVisibleRows = 9;
    
    NSInteger totalRows = 0;
    for (NSDictionary *section in _menuData) {
        totalRows += [section[@"items"] count] + 1;
    }
    CGFloat tableHeight = MIN(totalRows * rowHeight, maxVisibleRows * rowHeight);
    CGFloat menuHeight = headerHeight + tableHeight + 50;
    
    self.frame = CGRectMake((UIScreen.mainScreen.bounds.size.width - menuWidth)/2,
                           (UIScreen.mainScreen.bounds.size.height - menuHeight)/2,
                           menuWidth,
                           menuHeight);
    
    self.layer.cornerRadius = 15;
    self.clipsToBounds = YES;
    [self addBlurEffect];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, menuWidth-120, 30)];
    _titleLabel.text = @"抖音魔术师";
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    _titleLabel.textColor = [UIColor whiteColor];
    [self addSubview:_titleLabel];
    
    _exitButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _exitButton.frame = CGRectMake(10, 10, 50, 30);
    [_exitButton setTitle:@"退出" forState:UIControlStateNormal];
    [_exitButton setTitleColor:[UIColor systemRedColor] forState:UIControlStateNormal];
    [_exitButton addTarget:self action:@selector(exitButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_exitButton];
    
    _closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _closeButton.frame = CGRectMake(menuWidth-60, 10, 50, 30);
    [_closeButton setTitle:@"关闭" forState:UIControlStateNormal];
    [_closeButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(closeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_closeButton];
    
      // 表格视图
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, menuWidth, menuHeight-50) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.showsVerticalScrollIndicator = NO;
    [self addSubview:_tableView];

        // 头部视图
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, menuWidth, headerHeight)];
headerView.backgroundColor = [UIColor clearColor];

       // 避免毛玻璃效果紧贴菜单边缘
       CGFloat padding = 10.0;  
       CGFloat topSpacing = 20.0; 
       headerView.frame = CGRectMake(0, 0, menuWidth, headerHeight + topSpacing); // 增加间距

       // 添加毛玻璃效果到头部视图
       UIBlurEffect *headerBlurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
       UIVisualEffectView *headerBlurEffectView = [[UIVisualEffectView alloc] initWithEffect:headerBlurEffect];
       headerBlurEffectView.frame = CGRectMake(padding, padding, menuWidth - 2 * padding, headerHeight - 2 * padding); // 留出内边距
    headerBlurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  headerBlurEffectView.layer.cornerRadius = 15; // 圆角值
  headerBlurEffectView.clipsToBounds = YES;
[headerView addSubview:headerBlurEffectView];

       // 计算头像垂直居中的位置
       CGFloat avatarHeight = 70.0; // 头像的高度
       CGFloat avatarTopMargin = (headerHeight - avatarHeight) / 2; // 头像顶部距离计算

       // 创建头像并设置居中
       UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, avatarTopMargin, 70, 70)];

       //头像base64图片编码
NSString *base64ImageString = @"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";
NSData *imageData = [[NSData alloc] initWithBase64EncodedString:base64ImageString options:0];
UIImage *image = [UIImage imageWithData:imageData];
avatarImageView.image = image;
avatarImageView.layer.cornerRadius = 35;
avatarImageView.clipsToBounds = YES;
[headerView addSubview:avatarImageView];

UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 25, menuWidth - 115, 20)];
nameLabel.text = @"抖音，永远停不下来！";
nameLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightBold];
[headerView addSubview:nameLabel];

UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 45, menuWidth - 115, 60)];
infoLabel.numberOfLines = 3;
infoLabel.text = @"版本: 1.1 (DYYY-2.1-2)\n严禁用于非法用途，仅用于测试！";
infoLabel.font = [UIFont systemFontOfSize:12];
[headerView addSubview:infoLabel];

self.tableView.tableHeaderView = headerView;

    // 添加尾部视图
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, menuWidth, 90)];
    footerView.backgroundColor = [UIColor clearColor];

    UIButton *authorButton = [UIButton buttonWithType:UIButtonTypeSystem];
    authorButton.frame = CGRectMake(10, 10, menuWidth - 20, 20);
    [authorButton setTitle:@"Developer By @huamidev" forState:UIControlStateNormal];
    [authorButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    [authorButton addTarget:self action:@selector(openAuthorLink) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:authorButton];

    UIButton *tgButton = [UIButton buttonWithType:UIButtonTypeSystem];
    tgButton.frame = CGRectMake(10, 35, menuWidth - 20, 20);
    [tgButton setTitle:@"UI Design By @iosxuuz" forState:UIControlStateNormal];
    [tgButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    [tgButton addTarget:self action:@selector(openUILink) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:tgButton];

    UIButton *buildButton = [UIButton buttonWithType:UIButtonTypeSystem];
    buildButton.frame = CGRectMake(10, 60, menuWidth - 20, 20);
    [buildButton setTitle:@"Build By @ae86_ios" forState:UIControlStateNormal];
    [buildButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    [buildButton addTarget:self action:@selector(openBUILDLink) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:buildButton];

    self.tableView.tableFooterView = footerView;

}

- (void)openAuthorLink {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/huami1314/DYYY"] options:@{} completionHandler:nil];
}

- (void)openUILink {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://t.me/iosxuuz"] options:@{} completionHandler:nil];
}

- (void)openBUILDLink {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://t.me/ae86_ios"] options:@{} completionHandler:nil];
}

#pragma mark - 毛玻璃效果

- (void)addBlurEffect {
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurView.frame = self.bounds;
    blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self insertSubview:blurView atIndex:0];
}

#pragma mark - UITableView 数据源与代理

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _menuData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  
    NSArray *items = _menuData[section][@"items"];
    
    BOOL expanded = [_expandedSections containsObject:@(section)];
        
    return expanded ? (items.count + 1) : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ParentCellID = @"ParentCell";
    static NSString *ChildCellID = @"ChildCell";
    CGFloat padding = 12.0;

    if (indexPath.row == 0) {
        // 父项单元格
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ParentCellID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ParentCellID];
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            // 毛玻璃背景
            UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            blurView.tag = 100;
            [cell.contentView insertSubview:blurView atIndex:0];

            // 标题
            cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
            cell.textLabel.textColor = [UIColor whiteColor];

            // 箭头
            UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectZero];
            arrow.tag = 200;
            arrow.tintColor = [UIColor lightGrayColor];
            [cell.contentView addSubview:arrow];
        }

        // 配置内容
        UIVisualEffectView *blurView = [cell.contentView viewWithTag:100];
        CGFloat cellWidth = CGRectGetWidth(tableView.frame); 
        blurView.frame = CGRectMake(padding, 0, cellWidth - 2*padding, CGRectGetHeight(cell.contentView.bounds));

        UIImageView *arrow = [cell.contentView viewWithTag:200];
        BOOL expanded = [_expandedSections containsObject:@(indexPath.section)];
        arrow.image = [UIImage systemImageNamed:expanded ? @"chevron.down" : @"chevron.right"];
        arrow.frame = CGRectMake(CGRectGetWidth(blurView.frame) - 30, (CGRectGetHeight(blurView.frame)-20)/2, 20, 20);

        // 父项圆角处理
        blurView.layer.cornerRadius = 8;
        blurView.layer.masksToBounds = YES; 

        if (expanded) {
            // 父项展开时，不保留底部圆角
            blurView.layer.maskedCorners = (CACornerMask)(kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner); // 只保留顶部圆角
        } else {
            // 父项未展开时，四个角都有圆角
            blurView.layer.maskedCorners = (CACornerMask)(kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner);
        }

        cell.textLabel.text = _menuData[indexPath.section][@"title"];
        return cell;
    } else {
        // 子项单元格
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ChildCellID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ChildCellID];
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            // 毛玻璃背景
            UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            blurView.tag = 100;
            [cell.contentView insertSubview:blurView atIndex:0];

            // 文本样式
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
            cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        }

        // 配置内容
        UIVisualEffectView *blurView = [cell.contentView viewWithTag:100];
        CGFloat cellWidth = CGRectGetWidth(tableView.frame);
        blurView.frame = CGRectMake(padding, 0, cellWidth - 2*padding, CGRectGetHeight(cell.contentView.bounds));

        NSDictionary *item = _menuData[indexPath.section][@"items"][indexPath.row-1];
        cell.textLabel.text = [NSString stringWithFormat:@"• %@", item[@"name"]];

        // 子项圆角处理
        blurView.layer.masksToBounds = YES; // 确保子项圆角生效
        
        // 获取该 section 中的子项数量
        NSInteger totalItemsInSection = [_menuData[indexPath.section][@"items"] count];
        
        // 判断当前子项是否是最后一个子项
        if (indexPath.row == totalItemsInSection) {
            // 最后一个子项，只设置左右下角圆角
            blurView.layer.cornerRadius = 8;
            blurView.layer.maskedCorners = (CACornerMask)(kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner);
        } else {
            // 其他子项，不设置圆角
            blurView.layer.cornerRadius = 0;
            blurView.layer.maskedCorners = 0;
        }

        // 根据类型添加控件
        DYYYSettingItemType type = [item[@"type"] integerValue];
        switch (type) {
            case DYYYSettingItemTypeSwitch: {
                UISwitch *switchView = [[UISwitch alloc] init];
                switchView.on = [[NSUserDefaults standardUserDefaults] boolForKey:item[@"key"]];
                [switchView addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
                switchView.tag = indexPath.section * 100 + indexPath.row;
                cell.accessoryView = switchView;
                break;
            }
case DYYYSettingItemTypeTextField: {
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
    textField.placeholder = item[@"placeholder"];
    textField.text = [[NSUserDefaults standardUserDefaults] stringForKey:item[@"key"]];
    textField.textColor = [UIColor whiteColor];
    textField.font = [UIFont systemFontOfSize:14];
    textField.textAlignment = NSTextAlignmentRight;
    textField.returnKeyType = UIReturnKeyDone;  // 设置“确定”按钮
    
    // 绑定事件
    [textField addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    cell.accessoryView = textField;
    break;
}
    
case DYYYSettingItemTypeSpeedPicker: {
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UITextField *speedField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
    speedField.text = [NSString stringWithFormat:@"%.2fx", [[NSUserDefaults standardUserDefaults] floatForKey:@"DYYYDefaultSpeed"]];
    speedField.textColor = [UIColor whiteColor];
    speedField.font = [UIFont systemFontOfSize:14];
    speedField.textAlignment = NSTextAlignmentRight;  // 右对齐
    speedField.enabled = NO; // 设置为不可编辑
    cell.accessoryView = speedField;
    
    break;
            }
            default:
                break;
        }

        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        NSNumber *sectionKey = @(indexPath.section);
        if ([_expandedSections containsObject:sectionKey]) {
            [_expandedSections removeObject:sectionKey];  
        } else {
            [_expandedSections addObject:sectionKey];    
        }
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] 
                 withRowAnimation:UITableViewRowAnimationFade];
    } else {
        // 处理子项点击
        NSDictionary *item = _menuData[indexPath.section][@"items"][indexPath.row-1];
if ([item[@"type"] integerValue] == DYYYSettingItemTypeSpeedPicker) {

    [self showSpeedPicker];
}
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - 交互事件处理

- (void)switchValueChanged:(UISwitch *)sender {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag%100 inSection:sender.tag/100];
    NSDictionary *item = _menuData[indexPath.section][@"items"][indexPath.row-1];
    
    // 保存开关状态到NSUserDefaults
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:item[@"key"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 显示Toast提示
    NSString *status = sender.isOn ? @"已开启" : @"已关闭";
    CustomToastView *toast = [[CustomToastView alloc] initWithTitle:item[@"name"] subtitle:status icon:nil autoHide:2];
    [toast presentToast];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    // 获取当前cell
    UIView *cell = textField.superview;
    while (![cell isKindOfClass:[UITableViewCell class]]) {
        cell = cell.superview;
    }
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)cell];
    NSDictionary *item = _menuData[indexPath.section][@"items"][indexPath.row-1];
    
    // 保存数据
    [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:item[@"key"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 显示Toast提示
    CustomToastView *toast = [[CustomToastView alloc] initWithTitle:item[@"name"] subtitle:[NSString stringWithFormat:@"已保存: %@", textField.text] icon:nil autoHide:2];
    [toast presentToast];
    
    // 关闭键盘
    [textField resignFirstResponder];
}

- (void)showSpeedPicker {

    [CustomMenuView hideMenu];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择倍速" message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    NSArray *speeds = @[@0.5, @0.75, @1.0, @1.25, @1.5, @2.0];
    for (NSNumber *speed in speeds) {
        [alert addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%.2fx", speed.floatValue]
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {

            [CustomMenuView showMenu];

            // 保存所选倍速到 UserDefaults
            [[NSUserDefaults standardUserDefaults] setFloat:speed.floatValue forKey:@"DYYYDefaultSpeed"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            [self updateTableView];

            // 重新加载特定的行，而不是全表刷新
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0]; // 修改为实际的行和节索引
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }]];
    }

    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [CustomMenuView showMenu]; 
    }]];

    UIViewController *viewController = [self currentViewController];
    if (viewController) {
        [viewController presentViewController:alert animated:YES completion:nil];
    }
}

// 获取当前视图控制器的辅助方法
- (UIViewController *)currentViewController {
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (rootViewController.presentedViewController) {
        rootViewController = rootViewController.presentedViewController;
    }
    return rootViewController;
}

#pragma mark - 其他方法
+ (CustomMenuWindow *)sharedMenuWindow {
    static CustomMenuWindow *sharedWindow = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedWindow = [[CustomMenuWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    });
    return sharedWindow;
}

+ (void)showMenu {
    [self.sharedMenuWindow setHidden:NO];
}

+ (void)hideMenu {
    [self.sharedMenuWindow setHidden:YES];
}

- (void)updateTableView {
    [self.tableView reloadData];

}

- (void)exitButtonTapped:(UIButton *)sender {

    [[UIApplication sharedApplication] performSelector:@selector(suspend)];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIApplication *app = [UIApplication sharedApplication];
        [app performSelector:@selector(terminateWithSuccess)];
    });
}

- (void)closeButtonTapped:(UIButton *)sender {
    [CustomMenuView hideMenu];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
