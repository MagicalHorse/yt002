//
//  FSPostTableSelViewController.m
//  FashionShop
//
//  Created by gong yi on 12/13/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSPostTableSelViewController.h"
#import "UIViewController+Loading.h"

@interface FSPostTableSelViewController ()
{
    NSMutableArray *_data;
    PostTableDataSource _delegate;
    PostProgressStep _currentStep;
    id _target;
}



@end

@implementation FSPostTableSelViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self prepareData];
    [self presentControl];
}

-(void) setDataSource:(PostTableDataSource)source step:(PostProgressStep)current selectedCallbackTarget:(id)target
{
    _delegate = source;
    _currentStep = current;
    _target = target;
}

-(void) prepareData
{
    if (_delegate)
        _data = _delegate();
}

-(void) presentControl
{
    [self replaceBackItem];
    _tbContent.delegate = self;
    _tbContent.dataSource = self;
}

#pragma UITableViewSource delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _data?_data.count:0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *detailCell =  [tableView dequeueReusableCellWithIdentifier:@"defaultcell"];
    if (!detailCell)
    {
        detailCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"defaultcell"];
    }
    id rowData = [_data objectAtIndex:indexPath.row];
    if ([rowData respondsToSelector:@selector(name)])
        detailCell.textLabel.text = [rowData name];
    return detailCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_target respondsToSelector:@selector(proPostStep:didCompleteWithObject:)])
       [ _target proPostStep:_currentStep didCompleteWithObject:[_data objectAtIndex:indexPath.row]];
    [self.navigationController popViewControllerAnimated:TRUE];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
