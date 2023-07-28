1. 删除远程仓库不需要的文件

[Git-从仓库中删除.idea文件夹](https://blog.csdn.net/leorx01/article/details/66968707) 

2. 从本地创建项目并上传到GitHub上面，使用命令行的方式

参考：[创建本地项目并上传GitHub](https://juejin.im/post/6844903779314171918)

3. [git常用命令大全](https://blog.csdn.net/halaoda/article/details/78661334)







#### 切换远程仓库地址

1. 先查看远程仓库地址

```sh
git remote -v
```

2. 设置新的远程仓库地址

```sh
git remote set-url origin http://.../xxx.git
ps:  http://.../xxx.git 表示切换的远程仓库地址
```

3. 查看分支

```sh
git branch -a  //查看远程分支
git branch   //查看本地分支
```

其中 `remote/*`开头的是远程分支。

4. 切换分支

```sh
git checkout -b develop origin/develop
ps : develop 表示分支
```

如果在查看所有分支之后，只有本地分支，需要运行 `git fetch` 或者是 `git pull` 命令，将最新的分支拉去下来。

`git fetch`是将远程主机的最新内容拉到本地，用户在检查了以后决定是否合并到工作本机分支中。

而`git pull` 则是将远程主机的最新内容拉下来后直接合并，即：`git pull = git fetch + git merge`，这样可能会产生冲突，需要手动解决。

https://www.cnblogs.com/runnerjack/p/9342362.html

##### 设置跟踪远程分支

```sh
>git branch --set-upstream-to origin/master
Branch 'master' set up to track remote branch 'master' from 'origin'.
```

https://juejin.cn/post/6929845334437085191

#### 修改本地分支名称

如果对于分支不是当前分支，可以使用下面代码： 

git branch -m "原分支名" "新分支名" 

如果是当前，那么可以使用加上新名字

 git branch -m "新分支名称"



