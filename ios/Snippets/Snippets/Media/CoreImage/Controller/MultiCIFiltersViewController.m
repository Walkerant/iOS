//
//  MultiCIFiltersViewController.m
//  Snippets
//
//  Created by Walker on 2020/12/17.
//  Copyright © 2020 Walker. All rights reserved.
//

#import "MultiCIFiltersViewController.h"
#import "CIFilterInputView.h"
#import "CIFilterInputModel.h"
#import "CIFilterInputViewModel.h"
#import "CIFilterAttributePanel.h"

API_AVAILABLE(ios(14))
@interface MultiCIFiltersViewController ()

@property (nonatomic) UIButton *filterCateButton;
@property (nonatomic) UIButton *filterNameButton;
@property (nonatomic) UIImageView *inputImageView;
@property (nonatomic) PHPickerConfiguration *config;
@property (nonatomic) PHPickerViewController *pickerController;
@property (nonatomic) CIFilterAttributePanel *attributePanel;

@property (nonatomic) UIImage *selectedImage;
@property (nonatomic, copy) NSString *filterName;

@end

@implementation MultiCIFiltersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    [self setupBarButtons];
    [self addObservers];
}

- (void)setupUI{
    [self.view addSubview:self.filterCateButton];
    [self.view addSubview:self.filterNameButton];
    [self.view addSubview:self.inputImageView];
}

- (void)setupBarButtons{
    UIBarButtonItem *process;
    
    process = [[UIBarButtonItem alloc] initWithTitle:@"处理" style:UIBarButtonItemStylePlain target:self action:@selector(processImage:)];
    
    self.navigationItem.rightBarButtonItem = process;
}

- (void)processImage:(UIBarButtonItem *)sender{
    CIFilter *filter = _attributePanel.inputModel.recentFilter;
    NSData *imageData = UIImageJPEGRepresentation(_selectedImage, .95);
    
    [filter setValue:[CIImage imageWithData:imageData] forKey:kCIInputImageKey];
    [_inputImageView setImage:[UIImage imageWithCIImage:filter.outputImage]];
}

- (void)filterCateChanged:(UIButton *)sender{
    static const NSArray *allCates;
    
    allCates = @[@"CICategoryBlur",@"CICategoryColorAdjustment",
                 @"CICategoryColorEffect", @"CICategoryCompositeOperation",
                 @"CICategoryDistortionEffect", @"CICategoryDistortionEffect",
                 @"CICategoryGeometryAdjustment", @"CICategoryGradient"];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择滤镜" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (NSString *cateName in allCates) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:cateName style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.filterCateButton setTitle:cateName forState:UIControlStateNormal];
        }];
        [alert addAction:action];
    }
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}

- (void)filterNameChanged:(UIButton *)sender{
    NSArray *filters = [CIFilter filterNamesInCategory:_filterCateButton.titleLabel.text];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择滤镜" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (NSString *filterName in filters) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:[CIFilter localizedNameForFilterName:filterName] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.filterNameButton setTitle:filterName forState:UIControlStateNormal];
            [self setFilterName:filterName];
        }];
        [alert addAction:action];
    }
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}

#pragma mark - PHPickerDelegate

- (void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results API_AVAILABLE(ios(14)){
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    NSItemProvider *privider = results.firstObject.itemProvider;
    if ([privider canLoadObjectOfClass:UIImage.class]) {
        [privider loadObjectOfClass:UIImage.class completionHandler:^(__kindof id<NSItemProviderReading>  _Nullable image, NSError * _Nullable error) {
            if (error || !image) {
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.inputImageView.image = image;
                self.selectedImage = image;
            });
        }];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint point = [touches.anyObject locationInView:self.view];
    if (CGRectContainsPoint(self.inputImageView.frame, point)) {
        [self presentViewController:self.pickerController animated:YES completion:^{
            
        }];
    }
}

#pragma mark - KVO

- (void)addObservers{
    [self addObserver:self forKeyPath:@"filterName" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"filterName"]) {
        [self configUIWithFilterName:change[NSKeyValueChangeNewKey]];
    }
}

- (void)configUIWithFilterName:(NSString *)filterName{
    if (!_attributePanel) {
        _attributePanel = [CIFilterAttributePanel panelWithName:filterName];
        [self.view addSubview:_attributePanel];
    } else {
        [_attributePanel updateName:filterName];
    }
    
    [self.view setNeedsLayout];
    [self.view setNeedsDisplay];
    [self.view layoutIfNeeded];
}

#pragma mark - Accessor

- (PHPickerConfiguration *)config API_AVAILABLE(ios(14)){
    if (!_config) {
        _config = [[PHPickerConfiguration alloc] init];
        _config.filter = PHPickerFilter.imagesFilter;
    }
    return _config;
}

- (PHPickerViewController *)pickerController API_AVAILABLE(ios(14)){
    if (!_pickerController) {
        _pickerController = [[PHPickerViewController alloc] initWithConfiguration:self.config];
        _pickerController.delegate = self;
    }
    return _pickerController;
}

- (UIButton *)filterCateButton{
    if (!_filterCateButton) {
        _filterCateButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_filterCateButton setTitle:@"CICategoryBlur" forState:UIControlStateNormal];
        [_filterCateButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_filterCateButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [_filterCateButton addTarget:self action:@selector(filterCateChanged:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _filterCateButton;
}
- (UIButton *)filterNameButton{
    if (!_filterNameButton) {
        _filterNameButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_filterNameButton setTitle:@"CIBokehBlur" forState:UIControlStateNormal];
        [_filterNameButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_filterNameButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [_filterNameButton addTarget:self action:@selector(filterNameChanged:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _filterNameButton;
}
- (UIImageView *)inputImageView{
    if (!_inputImageView) {
        _selectedImage = [UIImage imageNamed:@"blackboard.jpg"];
        _inputImageView = [[UIImageView alloc] init];
        _inputImageView.image = _selectedImage;
    }
    return _inputImageView;
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    CGFloat ivWidth = CGRectGetWidth(self.view.bounds)/2;
    CGFloat ivHeight = ivWidth*.75;
    CGPoint center = self.view.center;
    
    _inputImageView.frame = CGRectMake(0, 0, ivWidth, ivHeight);
    _inputImageView.center = CGPointMake(center.x, center.y-150);
    
    _filterCateButton.frame = CGRectMake(0, CGRectGetMinY(_inputImageView.frame)-66.f, ivWidth, 49.f);
    _filterNameButton.frame = CGRectMake(center.x, CGRectGetMinY(_inputImageView.frame)-66.f, ivWidth, 49.f);
    
    _attributePanel.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds)*.75);
    _attributePanel.center = CGPointMake(center.x, CGRectGetMaxY(self.view.bounds)-CGRectGetWidth(self.view.bounds));
}

@end
