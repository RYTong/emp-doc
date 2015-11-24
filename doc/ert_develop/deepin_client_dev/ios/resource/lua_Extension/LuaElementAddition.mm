//
//  LuaElementAddition.m
//  APP
//
//  Created by linjitao on 13-8-22.
//  Copyright (c) 2013年 RYTong. All rights reserved.
//

#import "LuaElementAddition.h"

@implementation LuaElement (Addition)


int test(lua_State *lua){
    ZNLog(@"lua element test");
    return 0;
}

int lua_newElementAdditionFunctionMetable(lua_State *lua){
    
    lua_pushcfunction(lua, test);
	lua_setfield(lua,-2,"test");
    
    return 0;
}

- (int)newElementFunctionMetable:(lua_State *)lua {
    int status = lua_newElementFunctionMetable(lua);//调用LuaElement.mm中的方法
    status = lua_newElementAdditionFunctionMetable(lua);
    return status;
}
@end
