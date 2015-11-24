//
//  LuaElementAddition.h
//  APP
//
//  Created by linjitao on 13-8-22.
//  Copyright (c) 2013年 RYTong. All rights reserved.
//

#import <LUAScript/LuaElement.h>
/*
 * 使用分类的方式扩展element方法
 */
@interface LuaElement (Addition)

int lua_newElementFunctionMetable(lua_State *lua);

- (int)newElementFunctionMetable:(lua_State *)lua;
@end
