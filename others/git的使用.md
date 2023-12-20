# git 的使用

---

## git 的配置

1. 查看 git 配置
	- 查看 git 系统配置
	```shell
	git config --system --list
	```
	- 查看 git 用户配置
	```shell
	git config --global --list
	```
2. 修改 git 配置
	```shell
	# 格式
	git config [type] [key] [value]
	# 修改用户名
	git config --global user.name "ABC"
	# 修改邮箱
	git config --global user.email "123@qq.com"
	```

3. 删除 git 配置
	```shell
	git config --global --unset <设置名称>
	```
	
## git 本地仓库的使用

1. 初始化仓库(在一个新建的文件夹中)
	```shell
	git init # 会生成.git隐藏文件夹
	```

2. 克隆远程仓库(将远程仓库的内容复制,需要权限)
	```shell
	# 克隆就不需要初始化了
	git clone <远程仓库链接> # 链接http什么的应该都可以
	```
	
3. 查看文件状态
	```shell
	git status [filename] # 缺省会显示所有仓库文件
	```
	>文件的状态:
	>	1. __Untracked__	文件在文件夹中但是没有加入git仓库
	>	2. __Unmodify__		正常在git仓库中的文件
	>	3. __Modified__		git仓库中修改过的文件
	>	4. __Staged__		加入git暂存区的文件(暂存区在提交后会变成 __Unmodify__ )

4. 将文件加入暂存区
	```shell
	git add [filepath] ### [filepath]如果是 "." 则代表所有文件
	```
	
5. 将暂存区文件提交
	```shell
	git commit -m "info" # info 表示这次提交附带的comment
	```
	
6. 取消对一个文件的追踪(可以配合.gitignore)
	```shell
	git rm –-cached [-rf] [filepath] # -rf 代表强制递归取消跟踪
	# 特别针对与之前忘记写.gitignore的情况,先全部取消跟踪再git add . 就可以了
	```
	
7. 查看提交记录
	```shell
	git log [option]
	# --all 			显示所有
	# --pretty=oneline	所有信息显示在一行
	# --abbrev-commit	简略commitId
	# --graph			显示图标
	```
	
8. 版本回退
	```shell
	git reset --hard <commitId> # git log 可获得<commitId>
	```

9. 增强版查看提交记录(包括回退的记录)
	```shell
	git reflog
	```
	
	
## git 分支

##### git 分支就相当于复制了一个一模一样的文件夹,在切换分支时就像切换不同文件夹

1. 列出分支
	```shell
	git branch
	```

2. 新建分支
	```shell
	git branch <branchname>
	```

3. 切换分支
	```
	git checkout <branchname>
	```
	
4. 合并目标分支至当前分支
	```shell
	git merge <target branchname>
	# 合并分支就是让目标分支与当前分支的内容同步
	# 如果有冲突报错
	```
	
5. 删除分支
	```shell
	git branch -d <branchname>
	```
	

## git 远程仓库

1. 连接至远程仓库
	```shell
	git remote add <远程仓库名> <仓库URL>
	# 如无特殊情况远程仓库名始终默认为 origin
	```

2. 列出远程分支
	```shell
	git branch -r
	```

3. 将当前分支与远程分支建立联系
	```shell
	git push --set-upstream <远程仓库名> <远端分支名>
	# 建立联系需要依托push或pull或fetch的操作
	# 如无特殊情况远端默认分支名为master或main,gitee应该是master,github应该是main
	```
	
4. 创建远程分支
	```
	# 同上
	# 与远程分支建立联系时,如果远程分支不存在就新建一个远程分支
	```
	
5. 删除远程分支
	```shell
	git push <远程仓库名> --delete <remote branchname>
	```
	
6. 将当前本地分支内容推送到对应远程分支
	```shell
	git push [-f]
	# 如果没有与远程分支建立联系需要先 --set-upstream
	# 在 push 中 -u 和 --set--upstream 有着相同的效果
	# -f 代表强制推送,强制用本地分支覆盖远程分支 (没事千万别搞这个!!!)
	```
	
7. 将远端分支拉取到本地
	```shell
	git fetch
	# 如果没有与远程分支建立联系需要先 --set-upstream
	# fetch 中没有 -u
	# 拉取到的结果会保留在系统提供的 FETCH_HEAD 分支中,你需要手动进行 merge 合并
	```
	
8. 将远端分支拉取到本地并进行合并
	```shell
	git pull
	# 如果没有与远程分支建立联系需要先 --set-upstream
	# pull 中没有 -u
	# 自动将拉取的结果与当前合并,相当于 fetch + merge
	```

## .gitignore 文件

#### .gitignore 文件指定了哪些文件不应该在 git add . 中自动包含

格式:
```.gitignore
# 	这是注释
** 	表示任意多级目录
* 	这是通配符
!	这是指定包含的文件(假如在它上面制定了一些规则覆盖了该文件,你可以用!取消)
[]	匹配多个[]之内的字符(比如[abc])

例子:
**/abc.txt	# 忽略所有目录下的abc.txt
abc.txt		# 忽略当前目录下的abc.txt
*.txt		# 忽略当前目录下的所有后缀名为.txt的文件
!a1.txt		# 取消对当前目录下a1.txt的忽略
abc/		# 忽略当前目录下的的abc文件夹
**/abc/		# 忽略所有目录下的abc文件夹
```

## git 为指令创建别名

```shell
git config --global alias.<指令名> "被替换的指令"
# 例如:
git config --global alias.gl "log --all --pretty=oneline --abbrev-commit --graph"
# 之后使用 git gl 就可以执行这条命令了
```