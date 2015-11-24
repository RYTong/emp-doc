//
//  LuaElementAddition.h
//  APP
//
//  Created by linjitao on 13-8-22.
//  Copyright (c) 2013年 RYTong. All rights reserved.
//

#import <LUAScript/LuaElement.h>

@interface LuaElement (Addition)

int lua_newElementFunctionMetable(lua_State *lua);

- (int)newElementFunctionMetable:(lua_State *)lua;
@end
