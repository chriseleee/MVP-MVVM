# MVP-MVVM
MVP&amp;&amp;MVVM
简书地址:(https://www.jianshu.com/p/121ccf669029)
前面说到了[iOS 从MVC到MVP](https://www.jianshu.com/p/52ab0373a1ed)，最后说到：如果到时候业务复杂、逻辑复杂，更新界面的方法有多个(弹框、菊花等等的)，可以通过代理的多个方法实现。这样当然可以，但有没有更简单直接明了的方法呢？接着就产生了MVVM。
本文我们先通过实现一个小功能来了解MVVM：
有必要的请先下载[Demo](https://github.com/chriseleee/MVP-MVVM)
![功能效果图](https://upload-images.jianshu.io/upload_images/3807682-e8785d138f4089d1.gif?imageMogr2/auto-orient/strip)
每一项数据的变化都会反应在右上角的合计上。数据可以增、删、减。
我分别用MVP和MVVM实现了相关的功能。
![代码框架](https://upload-images.jianshu.io/upload_images/3807682-e9648dc3258fa319.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

其中代码的共用部分`LMDataSource`是应用代理模式来对VC中tableView代码的提取，VC中添加TableView只需要一句代码即可搞定：
```
//-------------tableView相关操作
/**
     cellConfigureBefore:cell的数据设置
     selectBlock: 点击cell的回掉
     reloadData: 删除数据、添加数据后的回掉
     */
    self.dataSource = [[LMDataSource alloc] initWithIdentifier:reuserId configureBlock:^(MVPTableViewCell *cell, Model *model, NSIndexPath *indexPath) {

        cell.nameLabel.text = model.name;
        cell.numLabel.text  = model.num;
        cell.num = [model.num intValue];
        cell.indexPath      = indexPath;
        cell.delegate       = weakSelf.vm;
    } selectBlock:^(NSIndexPath *indexPath) {
        NSLog(@"点击了%ld行cell", (long)indexPath.row);
    } reloadData:^(NSMutableArray *array) {
        weakSelf.vm.dataArray = array;
    }];
self.tableView.dataSource = self.dataSource;
self.tableView.delegate = self.dataSource;
```
`MVPTableViewCell`是自定义cell，`PresentDalegate`是cell的点击代理方法
```
- (void)didClickAddBtn:(UIButton *)sender{
    if ([self.numLabel.text intValue]>=200) {return;}
    self.num++;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickAddBtnWithNum:indexPath:)]) {
        [self.delegate didClickAddBtnWithNum:self.numLabel.text indexPath:self.indexPath];
    }
}
```
###1、MVP的实现
#####1.1 MVP中的Present
```
#pragma mark - lazy

- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithCapacity:10];
    }
    return _dataArray;
}

- (instancetype)init{
    if (self = [super init]) {
        [self loadData];
    }
    return self;
}


- (void)loadData{
    
    NSArray *temArray =
    @[
      @{@"name":@"火车",@"imageUrl":@"http://CC",@"num":@"1"},
      @{@"name":@"飞机",@"imageUrl":@"http://James",@"num":@"1"},
      @{@"name":@"跑车",@"imageUrl":@"http://Gavin",@"num":@"1"},
      @{@"name":@"女票",@"imageUrl":@"http://Cooci",@"num":@"1"},
      @{@"name":@"男票",@"imageUrl":@"http://Dean ",@"num":@"1"},
      @{@"name":@"滑板",@"imageUrl":@"http://CC",@"num":@"1"},
      @{@"name":@"一日游",@"imageUrl":@"http://James",@"num":@"1"}];
    for (int i = 0; i<temArray.count; i++) {
        Model *m = [Model modelWithDictionary:temArray[i]];
        [self.dataArray addObject:m];
    }
}


#pragma mark - PresentDelegate
- (void)didClickAddBtnWithNum:(NSString *)num indexPath:(NSIndexPath *)indexPath{

    for (int i = 0; i<self.dataArray.count; i++) {
        // 查数据 ---> 钱
        if (i == indexPath.row) {// 商品ID 容错
            Model *m = self.dataArray[indexPath.row];
            m.num    = num;
            break;
        }
    }
    
    if ([num intValue] > 6) {
        NSArray *temArray =
        @[
          @{@"name":@"火车",@"imageUrl":@"http://CC",@"num":@"6"},
          @{@"name":@"飞机",@"imageUrl":@"http://James",@"num":@"6"},
          @{@"name":@"跑车",@"imageUrl":@"http://Gavin",@"num":@"6"},
          @{@"name":@"女票",@"imageUrl":@"http://Cooci",@"num":@"6"},
          @{@"name":@"男票",@"imageUrl":@"http://Dean ",@"num":@"6"},
          @{@"name":@"滑板",@"imageUrl":@"http://CC",@"num":@"6"},
          @{@"name":@"一日游",@"imageUrl":@"http://James",@"num":@"6"}];
        [self.dataArray removeAllObjects];
        for (int i = 0; i<temArray.count; i++) {
            Model *m = [Model modelWithDictionary:temArray[i]];
            [self.dataArray addObject:m];
        }

    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(reloadDataForUI)]) {
        [self.delegate reloadDataForUI];
    }
}

#pragma mark 计算总数
-(int)total{
    int total = 0;
    for (Model* dic in self.dataArray) {
        int num = [dic.num intValue];
        total += num;
    }
    return total;
}
```
代码中除去初始化、获取数据，就只剩下cell的代理实现。其中在cell的代理实现中数据处理完成后，又通过一个代理让VC刷新数据![通过代理，让VC来刷新数据](https://upload-images.jianshu.io/upload_images/3807682-05afeb9927526e0d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

1.2 MVP中的V(ViewController)
```
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        [_tableView registerClass:[MVPTableViewCell class] forCellReuseIdentifier:reuserId];
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pt = [[Present alloc] init];
    __weak typeof(self) weakSelf = self;
    //-------------tableView相关操作
    /**
     cellConfigureBefore:cell的数据设置
     selectBlock: 点击cell的回掉
     reloadData: 删除数据、添加数据后的回掉
     */
    self.dataSource = [[LMDataSource alloc] initWithIdentifier:reuserId configureBlock:^(MVPTableViewCell *cell, Model *model, NSIndexPath *indexPath) {
        
        cell.nameLabel.text = model.name;
        cell.numLabel.text  = model.num;
        cell.num = [model.num intValue];
        cell.indexPath      = indexPath;
        cell.delegate       = weakSelf.pt;
    } selectBlock:^(NSIndexPath *indexPath) {
        NSLog(@"点击了%ld行cell", (long)indexPath.row);
    } reloadData:^(NSMutableArray *array) {
        weakSelf.pt.dataArray = [array copy];
        [weakSelf reloadDataForUI];
    }];
    
    [self.dataSource addDataArray:self.pt.dataArray];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self.dataSource;
    //Present代理设置
    self.pt.delegate          = self;
    
    self.navigationItem.rightBarButtonItem.title = [NSString stringWithFormat:@"合计:%d",[self.pt total]];
}

#pragma mark - PresentDelegate
- (void)reloadDataForUI{
    [self.dataSource addDataArray:self.pt.dataArray];
    [self.tableView reloadData];
    self.navigationItem.rightBarButtonItem.title = [NSString stringWithFormat:@"合计:%d",[self.pt total]];
}
```
代码很简单，其中包含：tableView的处理，Present的设置及其代理的设置，然后就是Present代理方法实现。整体结构还算清晰。
但有两点，第一:`reloadDataForUI`这里，有两个地方调用，一个是代理，一个是`LMDataSource `的reloadData中需要刷新列表。第二：cell的代理Present，在cell的代理方法里面又包含Present的代理VC。整体效果不太友好。有没有更好的办法呢？于是就有了MVVM。
###2、MVVM
#####2.1、MVVM中的ViewModel
```
#pragma mark - lazy

- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithCapacity:1];
    }
    return _dataArray;
}


- (instancetype)init{
    if (self==[super init]) {
        [self addObserver:self forKeyPath:@"dataArray" options:(NSKeyValueObservingOptionNew) context:nil];
    }
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    NSLog(@"%@ change",change[NSKeyValueChangeNewKey]);

    self.successBlock(change[NSKeyValueChangeNewKey]);
}

-(void)dealloc{
    [self removeObserver:self forKeyPath:@"dataArray"];
}

-(void)loadData{
    
    dispatch_queue_t q = dispatch_queue_create("udpios", DISPATCH_QUEUE_CONCURRENT);
    
    //2.异步执行任务
    dispatch_async(q, ^{
        
        NSArray *temArray = @[
                              @{@"name":@"火车",@"imageUrl":@"http://CC",@"num":@"1"},
                              @{@"name":@"飞机",@"imageUrl":@"http://James",@"num":@"1"},
                              @{@"name":@"跑车",@"imageUrl":@"http://Gavin",@"num":@"1"},
                              @{@"name":@"女票",@"imageUrl":@"http://Cooci",@"num":@"1"},
                              @{@"name":@"男票",@"imageUrl":@"http://Dean ",@"num":@"1"},
                              @{@"name":@"滑板",@"imageUrl":@"http://CC",@"num":@"1"},
                              @{@"name":@"一日游",@"imageUrl":@"http://James",@"num":@"1"}];
        [self.dataArray removeAllObjects];
        for (int i = 0; i<temArray.count; i++) {
            Model *m = [Model modelWithDictionary:temArray[i]];
            [self.dataArray addObject:m];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            // main更新代码
            self.successBlock(self.dataArray);
        });
        
        
    });
    
}
#pragma mark - PresentDelegate
- (void)didClickAddBtnWithNum:(NSString *)num indexPath:(NSIndexPath *)indexPath{
    
    for (int i = 0; i<self.dataArray.count; i++) {
        // 查数据 ---> 钱
        if (i == indexPath.row) {// 商品ID 容错
            Model *m = self.dataArray[indexPath.row];
            m.num    = num;
            break;
        }
    }
    
    
    if ([num intValue] > 6) {
        NSArray *temArray =
        @[
          @{@"name":@"火车",@"imageUrl":@"http://CC",@"num":@"6"},
          @{@"name":@"飞机",@"imageUrl":@"http://James",@"num":@"6"},
          @{@"name":@"跑车",@"imageUrl":@"http://Gavin",@"num":@"6"},
          @{@"name":@"女票",@"imageUrl":@"http://Cooci",@"num":@"6"},
          @{@"name":@"男票",@"imageUrl":@"http://Dean ",@"num":@"6"},
          @{@"name":@"滑板",@"imageUrl":@"http://CC",@"num":@"6"},
          @{@"name":@"一日游",@"imageUrl":@"http://James",@"num":@"6"}];
        [self.dataArray removeAllObjects];
        for (int i = 0; i<temArray.count; i++) {
            Model *m = [Model modelWithDictionary:temArray[i]];
            [self.dataArray addObject:m];
        }
        
    }
    self.successBlock(self.dataArray);
}

-(int)total{
    int total = 0;
    for (Model* dic in self.dataArray) {
        int num = [dic.num intValue];
        total += num;
    }
    return total;
}
```
对比MVP中的P，代码变多了，多了对dataArray的监听，监听到变化以后调用`self.successBlock()`。还有一点，cell的代理实现方法中，数据处理完以后，也是调用`self.successBlock()`

2.2、MVVM中的V(ViewController)
```
#pragma mark lazy
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        [_tableView registerClass:[MVPTableViewCell class] forCellReuseIdentifier:reuserId];
    }
    return _tableView;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"合计：" style:(UIBarButtonItemStyleDone) target:self action:nil];
    
    __weak __typeof(self) weakSelf = self;
    
    //-------------tableView相关操作
    /**
     cellConfigureBefore:cell的数据设置
     selectBlock: 点击cell的回掉
     reloadData: 删除数据、添加数据后的回掉
     */
    self.dataSource = [[LMDataSource alloc] initWithIdentifier:reuserId configureBlock:^(MVPTableViewCell *cell, Model *model, NSIndexPath *indexPath) {

        cell.nameLabel.text = model.name;
        cell.numLabel.text  = model.num;
        cell.num = [model.num intValue];
        cell.indexPath      = indexPath;
        cell.delegate       = weakSelf.vm;
    } selectBlock:^(NSIndexPath *indexPath) {
        NSLog(@"点击了%ld行cell", (long)indexPath.row);
    } reloadData:^(NSMutableArray *array) {
        weakSelf.vm.dataArray = array;
    }];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self.dataSource;
    
   
    //--------------ViewModel的操作
    self.vm = [[MVVMViewModel alloc]init];
    [self.vm initWithBlock:^(id data) {

        weakSelf.dataSource.dataArray = [weakSelf.vm.dataArray mutableCopy];
        [weakSelf.tableView reloadData];
        weakSelf.navigationItem.rightBarButtonItem.title = [NSString stringWithFormat:@"合计:%d",[weakSelf.vm total]];
        
        
    } fail:nil];
    
    
    //加载数据
    [self.vm loadData];

}


-(void)dealloc{
    NSLog(@"dealloc--%@",self);
}
```
什么，如此简单，代码就在ViewDidLoad里面实现完了。
对比MVP，Present变成了ViewModel，前面Present代理方法刷新数据变成了VM的`initWithBlock`。
`LMDataSource `中reloadData中只设置了ViewModel的dataArray的值。为什么都不用调用刷新界面的方法呢，原来在ViewModel设置了对dataArray的监听，只要监听到dataArray变化，就会执行VM的self.successBlock(),也就是进入了VC的VM的`initWithBlock`中。完美。

###3、MVVM 的基本概念

![MVVM](https://upload-images.jianshu.io/upload_images/3807682-f10f2cdf99f4de05.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


在MVVM 中，view 和 view controller正式联系在一起，我们把它们视为一个组件

view 和 view controller 都不能直接引用model，而是引用视图模型（viewModel）

viewModel 是一个放置用户输入验证逻辑，视图显示逻辑，发起网络请求和其他代码的地方

使用MVVM会轻微的增加代码量，但总体上减少了代码的复杂性

#####MVVM 的注意事项
view 引用viewModel ，但反过来不行（即不要在viewModel中引入#import UIKit.h，任何视图本身的引用都不应该放在viewModel中）（PS：基本要求，必须满足）

viewModel 引用model，但反过来不行

#####MVVM 的使用建议
MVVM 可以兼容你当下使用的MVC架构。

MVVM 增加你的应用的可测试性。

MVVM 配合一个绑定机制效果最好（PS：ReactiveCocoa你值得拥有）。

viewController 尽量不涉及业务逻辑，让 viewModel 去做这些事情。

viewController 只是一个中间人，接收 view 的事件、调用 viewModel 的方法、响应 viewModel 的变化。

viewModel 绝对不能包含视图 view（UIKit.h），不然就跟 view 产生了耦合，不方便复用和测试。

viewModel之间可以有依赖。

viewModel避免过于臃肿，否则重蹈Controller的覆辙，变得难以维护。

#####MVVM 的优势
低耦合：View 可以独立于Model变化和修改，一个 viewModel 可以绑定到不同的 View 上

可重用性：可以把一些视图逻辑放在一个 viewModel里面，让很多 view 重用这段视图逻辑

独立开发：开发人员可以专注于业务逻辑和数据的开发 viewModel，设计人员可以专注于页面设计

可测试：通常界面是比较难于测试的，而 MVVM 模式可以针对 viewModel来进行测试

#####MVVM 的弊端
数据绑定使得Bug 很难被调试。你看到界面异常了，有可能是你 View 的代码有 Bug，也可能是 Model 的代码有问题。数据绑定使得一个位置的 Bug 被快速传递到别的位置，要定位原始出问题的地方就变得不那么容易了。

对于过大的项目，数据绑定和数据转化需要花费更多的内存（成本）。主要成本在于：

数组内容的转化成本较高：数组里面每项都要转化成Item对象，如果Item对象中还有类似数组，就很头疼。

转化之后的数据在大部分情况是不能直接被展示的，为了能够被展示，还需要第二次转化。

只有在API返回的数据高度标准化时，这些对象原型（Item）的可复用程度才高，否则容易出现类型爆炸，提高维护成本。

调试时通过对象原型查看数据内容不如直接通过NSDictionary/NSArray直观。

同一API的数据被不同View展示时，难以控制数据转化的代码，它们有可能会散落在任何需要的地方。

如果觉得有用可以下载[Demo](https://github.com/chriseleee/MVP-MVVM)了解更多。
如果对`LMDataSource`这个类的功能不太了解，这里是使用了代理模式，可以看看[设计模式--代理模式(iOS)](https://www.jianshu.com/p/ce3ccedc0717)
如果对`MVP`不太了解，可以看看[iOS 从MVC到MVP](https://www.jianshu.com/p/52ab0373a1ed)



写在最后：
希望这篇文章对您有帮助。当然如果您发现有可以优化的地方，希望您能慷慨的提出来。最后祝您工作愉快！





