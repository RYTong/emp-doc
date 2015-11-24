
## slt2介绍

在上面的例子中我们看到如果将初始化脚本写入lua文件中，整个xhtml报文内容特别少，很难看到界面的主要内容。如果我们能像以前写CS一样在body
中嵌入lua代码，这样界面报文看起来就能清楚明白很多。
以刚才的账户查询为例：
我们是否可以实现将报文这样拼接,lua语言的标记我们沿用cs中的习惯。
```
#{ for key, coll_list in pairs(coll_lists) do }#
    <tr>
        <td>
            <div class="tr_div"  border="0">
                <img src="local:balance_qry/images/logo.png" class="img_rytong"/>
                <label class="label_alias">#{= coll_list["acc_alias"]}#</label><br/>
                <label class="label_acc">#{= string.sub(coll_list["acc_no"],1,4) }#****#{= string.sub(coll_list["acc_no"],string.len(coll_list["acc_no"])-3,-1)}#</label>
                <img src="local:balance_qry/images/card_pull_but.png" class="img_onclick"/><br/>
                <label class="label_py">#{= coll_list["card_desc"]}#</label>
            </div>
        </td>
    </tr>
#{ end }#
```
那么我们的xhtml界面报文可以修改为这样，完整报文请参照：
[balance_qry_mb01.xhtml](images/balance_qry_mb01_slt2.xhtml)

那么这个时候就得考虑这个lua数据怎么传入xhtml文件。

有网上的大神实现了这个render，下面我们简单介绍一下此lua文件。

slt2.lua，slt2为Simple Lua Template 2的简写，为Lua模板处理程序，与php或jsp类似,您可以直接嵌入lua代码，具体请参照
![http://blog.henix.info/works/simple-lua-template/_.html](http://blog.henix.info/works/simple-lua-template/_.html)









## slt2引进
