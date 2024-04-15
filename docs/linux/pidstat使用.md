如果我们要查看Linux下面进程、进程组、线程的资源消耗的统计信息，可以使用pidstat，它可以收集并报告进程的统计信息。

pidstat实际上也是将/proc/pid下的统计信息统筹后展现给用户。

原文链接：https://blog.csdn.net/qq_40603010/article/details/118974693

#### 示例

```sh
pidstat [ 选项 ] [ <时间间隔> ] [ <次数> ]
// 
[tester@localhost doc]$ pidstat --help
Usage: pidstat [ options ] [ <interval> [ <count> ] ]
Options are:
[ -d ] [ -h ] [ -I ] [ -l ] [ -r ] [ -s ] [ -t ] [ -U [ <username> ] ] [ -u ]
[ -V ] [ -w ] [ -C <command> ] [ -p { <pid> [,...] | SELF | ALL } ]
[ -T { TASK | CHILD | ALL } ]
```

#### 参数详解：

```properties
常用的参数：

-u：默认的参数，显示各个进程的cpu使用统计
-r：显示各个进程的内存使用统计
-d：显示各个进程的IO使用情况
-p：指定进程号
-w：显示每个进程的上下文切换情况
-t：显示选择任务的线程的统计信息外的额外信息
-T { TASK | CHILD | ALL }
这个选项指定了pidstat监控的。TASK表示报告独立的task，CHILD关键字表示报告进程下所有线程统计信息。ALL表示报告独立的task和task下面的所有线程。
注意：task和子线程的全局的统计信息和pidstat选项无关。这些统计信息不会对应到当前的统计间隔，这些统计信息只有在子线程kill或者完成的时候才会被收集。
-V：版本号
-h：在一行上显示了所有活动，这样其他程序可以容易解析。
-I：在SMP环境，表示任务的CPU使用率/内核数量
-l：显示命令名和所有参数
```

##### 示例一：查看所有进程的 CPU 使用情况（-u -p ALL）

```sh
[tester@localhost doc]$ pidstat -u -p ALL
Linux 3.10.0-1062.12.1.el7.x86_64 (localhost)   04/15/2024      _x86_64_        (6 CPU)

02:53:28 PM   UID       PID    %usr %system  %guest    %CPU   CPU  Command
02:53:28 PM     0         1    0.01    0.02    0.00    0.03     4  systemd
02:53:28 PM     0         2    0.00    0.00    0.00    0.00     0  kthreadd
02:53:28 PM     0         4    0.00    0.00    0.00    0.00     0  kworker/0:0H
02:53:28 PM     0         6    0.00    0.00    0.00    0.00     0  ksoftirqd/0
02:53:28 PM     0         7    0.00    0.00    0.00    0.00     0  migration/0
02:53:28 PM     0         8    0.00    0.00    0.00    0.00     1  rcu_bh
02:53:28 PM     0         9    0.00    0.03    0.00    0.03     4  rcu_sched
02:53:28 PM     0        10    0.00    0.00    0.00    0.00     0  lru-add-drain
02:53:28 PM     0        11    0.00    0.00    0.00    0.00     0  watchdog/0
02:53:28 PM     0        12    0.00    0.00    0.00    0.00     1  watchdog/1
02:53:28 PM     0        13    0.00    0.00    0.00    0.00     1  migration/1
02:53:28 PM     0        14    0.00    0.00    0.00    0.00     1  ksoftirqd/1
02:53:28 PM     0        16    0.00    0.00    0.00    0.00     1  kworker/1:0H
02:53:28 PM     0        17    0.00    0.00    0.00    0.00     2  watchdog/2
02:53:28 PM     0        18    0.00    0.00    0.00    0.00     2  migration/2
02:53:28 PM     0        19    0.00    0.00    0.00    0.00     2  ksoftirqd/2
02:53:28 PM     0        21    0.00    0.00    0.00    0.00     2  kworker/2:0H
02:53:28 PM     0        22    0.00    0.00    0.00    0.00     3  watchdog/3
02:53:28 PM     0        23    0.00    0.00    0.00    0.00     3  migration/3
```

###### 输出字段详细说明

- PID：进程ID

- %usr：进程在用户空间占用cpu的百分比
- %system：进程在内核空间占用cpu的百分比
- %guest：进程在虚拟机占用cpu的百分比
- %CPU：进程占用cpu的百分比
- CPU：处理进程的cpu编号
- Command：当前进程对应的命令

##### 示例二: cpu使用情况统计(-u)

```sh
pidstat -u
```

使用-u选项，pidstat将显示各活动进程的cpu使用统计，执行”pidstat -u”与单独执行”pidstat”的效果一样。

##### 示例三： 内存使用情况统计(-r)

```sh
[tester@localhost doc]$ pidstat -r
Linux 3.10.0-1062.12.1.el7.x86_64 (localhost)   04/15/2024      _x86_64_        (6 CPU)

03:00:04 PM   UID       PID  minflt/s  majflt/s     VSZ    RSS   %MEM  Command
03:00:04 PM     0         1      0.16      0.00  194092   4432   0.07  systemd
03:00:04 PM     0       720      2.19      0.00   39656   4612   0.08  systemd-journal
03:00:04 PM     0       744      0.00      0.00  201128      0   0.00  lvmetad
03:00:04 PM     0       766      0.00      0.00   49040    480   0.01  systemd-udevd
03:00:04 PM     0      1031      0.07      0.03 5931632 298360   5.02  java
03:00:04 PM     0      1032      0.00      0.00   19376      0   0.00  rpc.idmapd
03:00:04 PM     0      1033      0.00      0.00   55528    184   0.00  auditd
03:00:04 PM     0      1035      0.00      0.00   84556    248   0.00  audispd
03:00:04 PM     0      1037      0.00      0.00   55644    240   0.00  sedispatch
03:00:04 PM    32      1060      0.00      0.00   69376    228   0.00  rpcbind
03:00:04 PM    81      1062      0.00      0.00   79964   1976   0.03  dbus-daemon
03:00:04 PM    70      1067      0.00      0.00   72548    724   0.01  avahi-daemon
03:00:04 PM   999      1068      1.78      0.00  630124   8240   0.14  polkitd
03:00:04 PM     0      1069      0.03      0.00   26424   1040   0.02  systemd-logind
03:00:04 PM    70      1072      0.00      0.00   72320      8   0.00  avahi-daemon
03:00:04 PM     0      1073      0.00      0.00  430612    836   0.01  ModemManager
```

###### 输出字段说明

- PID：进程标识符
- Minflt/s:任务每秒发生的次要错误，不需要从磁盘中加载页
- Majflt/s:任务每秒发生的主要错误，需要从磁盘中加载页
- VSZ：虚拟地址大小，虚拟内存的使用KB
- RSS：常驻集合大小，非交换区五里内存使用KB
- Command：task命令名

##### 示例四：显示各个进程的IO使用情况（-d）

```sh
[tester@localhost doc]$ pidstat -d
Linux 3.10.0-1062.12.1.el7.x86_64 (localhost)   04/15/2024      _x86_64_        (6 CPU)

03:01:18 PM   UID       PID   kB_rd/s   kB_wr/s kB_ccwr/s  Command
03:01:18 PM  1002      9610      0.17      0.03      0.00  bash
03:01:18 PM  1002     11250      0.00      0.00      0.00  bash
03:01:18 PM  1002     11264      0.00      0.00      0.00  bash
03:01:18 PM  1002     11429      0.00      0.00      0.00  top
03:01:18 PM  1002     14689      0.03      0.07      0.00  java
03:01:18 PM  1002     17259      0.00      0.00      0.00  bash
03:01:18 PM  1002     28886      0.02      0.02      0.00  java
```

###### 输出字段说明

- PID：进程id
- kB_rd/s：每秒从磁盘读取的KB
- kB_wr/s：每秒写入磁盘KB
- kB_ccwr/s：任务取消的写入磁盘的KB。当任务截断脏的pagecache的时候会发生。
- COMMAND:task的命令名

##### 示例五：显示每个进程的上下文切换情况（-w）

```sh
[tester@localhost doc]$ pidstat -w
Linux 3.10.0-1062.12.1.el7.x86_64 (localhost)   04/15/2024      _x86_64_        (6 CPU)

03:02:15 PM   UID       PID   cswch/s nvcswch/s  Command
03:02:15 PM     0         1      0.69      0.00  systemd
03:02:15 PM     0         2      0.00      0.00  kthreadd
03:02:15 PM     0         4      0.00      0.00  kworker/0:0H
03:02:15 PM     0         6      0.20      0.00  ksoftirqd/0
03:02:15 PM     0         7      0.46      0.00  migration/0
03:02:15 PM     0         8      0.00      0.00  rcu_bh
03:02:15 PM     0         9     15.05      0.00  rcu_sched
03:02:15 PM     0        10      0.00      0.00  lru-add-drain
03:02:15 PM     0        11      0.25      0.00  watchdog/0
03:02:15 PM     0        12      0.25      0.00  watchdog/1
03:02:15 PM     0        13      0.45      0.00  migration/1
```

###### 输出字段说明

- PID:进程id
- Cswch/s:每秒主动任务上下文切换数量
- Nvcswch/s:每秒被动任务上下文切换数量
- Command:命令名

##### 示例六：显示选择任务的线程的统计信息外的额外信息 (-t)

```sh
[tester@localhost doc]$ pidstat -t -p 14689
Linux 3.10.0-1062.12.1.el7.x86_64 (localhost)   04/15/2024      _x86_64_        (6 CPU)

03:04:10 PM   UID      TGID       TID    %usr %system  %guest    %CPU   CPU  Command
03:04:10 PM  1002     14689         -    0.02    0.02    0.00    0.03     5  java
03:04:10 PM  1002         -     14689    0.00    0.00    0.00    0.00     5  |__java
03:04:10 PM  1002         -     14690    0.00    0.00    0.00    0.00     0  |__java
03:04:10 PM  1002         -     14691    0.00    0.00    0.00    0.00     4  |__java
03:04:10 PM  1002         -     14692    0.00    0.00    0.00    0.00     4  |__java
03:04:10 PM  1002         -     14693    0.00    0.00    0.00    0.00     4  |__java
03:04:10 PM  1002         -     14694    0.00    0.00    0.00    0.00     3  |__java
03:04:10 PM  1002         -     14695    0.00    0.00    0.00    0.00     5  |__java
03:04:10 PM  1002         -     14696    0.00    0.00    0.00    0.00     5  |__java
03:04:10 PM  1002         -     14697    0.00    0.00    0.00    0.00     0  |__java
03:04:10 PM  1002         -     14698    0.00    0.00    0.00    0.00     5  |__java
03:04:10 PM  1002         -     14699    0.00    0.00    0.00    0.00     5  |__java
```

###### 输出字段说明

- TGID:主线程的表示
- TID:线程id
- %usr：进程在用户空间占用cpu的百分比
- %system：进程在内核空间占用cpu的百分比
- %guest：进程在虚拟机占用cpu的百分比
- %CPU：进程占用cpu的百分比
- CPU：处理进程的cpu编号
- Command：当前进程对应的命令

##### 示例七：pidstat -T

```SH
[tester@localhost doc]$ pidstat -T ALL -p 14689
Linux 3.10.0-1062.12.1.el7.x86_64 (localhost)   04/15/2024      _x86_64_        (6 CPU)

03:05:54 PM   UID       PID    %usr %system  %guest    %CPU   CPU  Command
03:05:54 PM  1002     14689    0.02    0.02    0.00    0.03     5  java

03:05:54 PM   UID       PID    usr-ms system-ms  guest-ms  Command
03:05:54 PM  1002     14689   1991450   2254330         0  java
```

TASK表示报告独立的task。

CHILD关键字表示报告进程下所有线程统计信息。

ALL表示报告独立的task和task下面的所有线程。

注意：task和子线程的全局的统计信息和pidstat选项无关。这些统计信息不会对应到当前的统计间隔，这些统计信息只有在子线程kill或者完成的时候才会被收集。

- PID:进程id
- Usr-ms:任务和子线程在用户级别使用的毫秒数。
- System-ms:任务和子线程在系统级别使用的毫秒数。
- Guest-ms:任务和子线程在虚拟机(running a virtual processor)使用的毫秒数。
- Command:命令名
