#### 第一章节：

***

程序员想自己修改工资，但是肯定是会被发现的，所以就想办法不想被经理发现，所以想出的方法。    

方法：在另外一个模块写代码，然后导出为一个jar包，然后再使用URLClassLoader来进行加载这个jar包,随后再创建这个类.（所以在当前这个目录中没有了这个类，SalaryCaler.java这个类，取而代之的是在D:\developToolsAndSoft\jarpackage\salary.jar 中）    

> jar包可以放到那些地方?放到网络地址、maven仓库、drools规则引擎  

#### 第二章节:  

***

jar包都可以通过反编译的方式,被发现，所以我们要混淆这个class文件。

第一个想法：对class文件做手脚。  

- 修改.class文件的后缀，改为.myclass文件 。   

- 然后再自定义一个类加载器，去读取 .myclass文件。  

> 怎么实现自定义的类加载器？
>
> (1)继承一个