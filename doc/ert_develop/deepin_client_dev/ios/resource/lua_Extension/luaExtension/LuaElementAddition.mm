//
//  LuaElementAddition.m
//  APP
//
//  Created by linjitao on 13-8-22.
//  Copyright (c) 2013年 RYTong. All rights reserved.
//

#import "LuaElementAddition.h"
#import <Control/RYTControl.h>
#import "TableControl.h"
#import "DragDivControl.h"

@implementation LuaElement (Addition)

/*
 tableobject[1]:displaycell(tr,displayorhide)
 table折叠效果展开,收缩
 tr,需要隐藏或显示的tr
 displayorhide, bool变量,指明隐藏,或是显示的操作
 
 display = 1;
 function displaycell()
 local tables = document:getElementsByName('table1');
 local trs = document:getElementsByName('trtest');
 if display == 1 then
 tables[1]:displayCell(trs[1],true);
 display = 0;
 else
 tables[1]:displayCell(trs[1],false);
 display = 1;
 end
 end
 
 
 */
int displayCell(lua_State *lua){
    RYTControl *_control = (RYTControl *)lua_touserdata(lua, 1);
    RYTControl *_trControl = (RYTControl *)lua_touserdata(lua, 2);
    bool display = lua_toboolean(lua, 3);
    if (_control && _trControl && [_control isKindOfClass:[TableControl class]]) {
        TableControl *_table = (TableControl *)_control;
        [_table display:display cellControl:_trControl];
    }
    
    return 0;
}
//拖动控件定制接口 将控件加回父视图
int addToOriginalParentControl(lua_State *lua){
    RYTControl *_control = (RYTControl *)lua_touserdata(lua, 1);
    if (_control && [_control respondsToSelector:@selector(addToOriginalParentControl)]) {
        [_control performSelector:@selector(addToOriginalParentControl) withObject:nil];
    }
    return 0;
}

int lua_newElementAdditionFunctionMetable(lua_State *lua){
    
    lua_pushcfunction(lua, displayCell);
	lua_setfield(lua,-2,"displayCell");

    lua_pushcfunction(lua, addToOriginalParentControl);
	lua_setfield(lua,-2,"addToOriginalParentControl");
    
    return 0;
}

- (int)newElementFunctionMetable:(lua_State *)lua {
    int status = lua_newElementFunctionMetable(lua);//调用LuaElement.mm中的方法
    status = lua_newElementAdditionFunctionMetable(lua);
    return status;
}
@end
