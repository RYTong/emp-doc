# 公共控件命名规范

## 样式命名规范

公共控件是当前项目使用的控件列表，使用Panel面板添加。

我们规定公共控件样式命名前缀为`项目名_`,整体样式以样式属性命名。

具体的简写规则请参照[基础控件命名规范](./basic_tag_standard.html)中样式命名规范.

## 代码片段编码规范

其中部分编码规范请参照[基础控件命名规范](./basic_tag_standard.html)中代码片段编码规范。

### 使用预编译

建议项目中公共控件部分需要调用lua接口实现的效果使用slt实现，比如IOS7状态栏适配效果的代码:

```
#{local bar_flag = window:supportStatusBarInXML();}#
<div class="ert_position" align="center" valign="middle" border="0">
    #{if bar_flag then}#
    <div class="ert_w320_h20_blue" border = "0"></div>
    #{end}#
    <div class="ert_w320_h50_blue_f16w" align="center" valign="middle" border="0">
        <div class="ert_w50_h45_l10" border="0" valign="middle" >
            <img src="btn_back.png" class="ert_w8_h14"></img>
            <div class="ert_div_w10" border="0"></div>
            <input class="ert_f14w" type="button" value="返回" onclick="back_fun()"/>
        </div>
        <label class="ert_f18w">我的理财</label>
        <input class="ert_f14w_r10" type="button" value="首页" onclick="main_page()"/>
    </div>
</div>
```

slt介绍请参照[xhtml嵌套lua代码](../prerequisites/slt_code.html).

IOS7状态栏适配请参照[编程案例](../../xhtml_example/ios/ios_adaptation.html)中相关章节。

### lua脚本

在公共控件编写中会碰到需要编写lua脚本以实现某种效果，如果碰到这种情况时建议尽量将lua脚本使用`setOnClickListener`设置onclick监听。

具体请参照[基础控件命名规范](./basic_tag_standard.html)中添加绑定规则章节。
