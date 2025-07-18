#import "DYYYOptionsSelectionView.h"
#import <objc/runtime.h>
#import "AwemeHeaders.h"

@implementation DYYYOptionsSelectionView

+ (NSString *)showWithPreferenceKey:(NSString *)preferenceKey optionsArray:(NSArray<NSString *> *)optionsArray headerText:(NSString *)headerText onPresentingVC:(UIViewController *)presentingVC {
    return [self showWithPreferenceKey:preferenceKey optionsArray:optionsArray headerText:headerText onPresentingVC:presentingVC selectionChanged:nil];
}

+ (NSString *)showWithPreferenceKey:(NSString *)preferenceKey
                       optionsArray:(NSArray<NSString *> *)optionsArray
                         headerText:(NSString *)headerText
                     onPresentingVC:(UIViewController *)presentingVC
                   selectionChanged:(void (^)(NSString *selectedValue))callback {
    NSString *savedPreference = [[NSUserDefaults standardUserDefaults] stringForKey:preferenceKey];
    if (!savedPreference && optionsArray.count > 0) {
        savedPreference = optionsArray[0];
    }

    Class AWESettingItemModelClass = NSClassFromString(@"AWESettingItemModel");
    Class AWEPrivacySettingActionSheetConfigClass = NSClassFromString(@"AWEPrivacySettingActionSheetConfig");
    Class AWEPrivacySettingActionSheetClass = NSClassFromString(@"AWEPrivacySettingActionSheet");
    Class DUXContentSheetClass = NSClassFromString(@"DUXContentSheet");

    NSMutableArray *models = [NSMutableArray array];
    NSMutableArray *modelRefs = [NSMutableArray array];

    __block id contentSheet = nil;

    for (NSString *option in optionsArray) {
        id model = [[AWESettingItemModelClass alloc] initWithIdentifier:option];
        [model setTitle:option];
        [model setIsSelect:[savedPreference isEqualToString:option]];
        [models addObject:model];
        [modelRefs addObject:model];
    }

    for (int i = 0; i < modelRefs.count; i++) {
        id currentModel = modelRefs[i];
        [currentModel setCellTappedBlock:^{
          for (int j = 0; j < modelRefs.count; j++) {
              [modelRefs[j] setIsSelect:(j == i)];
          }

          NSString *selectedValue = [currentModel title];
          [[NSUserDefaults standardUserDefaults] setObject:selectedValue forKey:preferenceKey];
          [[NSUserDefaults standardUserDefaults] synchronize];

          if (callback) {
              callback(selectedValue);
          }

          if (contentSheet) {
              [contentSheet dismissViewControllerAnimated:YES completion:nil];
          }
        }];
    }

    id config = [[AWEPrivacySettingActionSheetConfigClass alloc] init];
    [config setModels:models];
    [config setHeaderText:headerText];
    [config setHeaderTitleText:@""];
    [config setNeedHighLight:NO];
    [config setUseCardUIStyle:YES];
    [config setFromHalfScreen:NO];
    [config setHeaderLabelIcon:nil];
    [config setSheetWidth:0];
    [config setAdaptIpadFromHalfVC:NO];

    id actionSheet = [AWEPrivacySettingActionSheetClass sheetWithConfig:config];

    UIViewController *containerVC = [[UIViewController alloc] init];
    [containerVC.view addSubview:actionSheet];

    UIView *sheetView = (UIView *)actionSheet;
    sheetView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [sheetView.leadingAnchor constraintEqualToAnchor:containerVC.view.leadingAnchor], [sheetView.trailingAnchor constraintEqualToAnchor:containerVC.view.trailingAnchor],
        [sheetView.topAnchor constraintEqualToAnchor:containerVC.view.topAnchor], [sheetView.bottomAnchor constraintEqualToAnchor:containerVC.view.bottomAnchor]
    ]];

    contentSheet = [[DUXContentSheetClass alloc] initWithRootViewController:containerVC withTopType:0 withSheetAligment:0];
    [contentSheet setAutoAlignmentCenter:YES];
    [contentSheet setSheetCornerRadius:10.0];

    [actionSheet setCloseBlock:^{
      [contentSheet dismissViewControllerAnimated:YES completion:nil];
    }];

    [contentSheet showOnViewController:presentingVC completion:nil];

    return savedPreference;
}

@end