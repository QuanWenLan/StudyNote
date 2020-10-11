#### 理解GC日志，[通过案例](https://mp.weixin.qq.com/s/0LGrSEv5MPVL0qM33T0UkQ)  
```Java
public class TestListWithBigData {
    public static void main(String[] args) {
        ArrayList<Integer> list0 = new ArrayList<>();
        ArrayList<Integer> list1 = new ArrayList<>();
        long start0 = System.currentTimeMillis();
        for (int i = 0; i < 10000000; i++) {
            list0.add(i);
        }
        System.out.println(System.currentTimeMillis()-start0); // 4007
        long start1 = System.currentTimeMillis();
        for (int i = 0; i < 10000000; i++) {
            list1.add(i);
        }
        System.out.println(System.currentTimeMillis()-start1); // 421
        // 两者的时间不一致, 添加jvm参数 -XX:+PrintGCDetails -XX:+PrintGCDateStamps
		// 两者的时间不一致, 添加jvm参数 -XX:+PrintGCDetails -XX:+PrintGCDateStamps
        // 添加虚拟机参数-Xms100M 堆的初始化大小
        /**
         * 前者时间一直都比后面的时间要长，因为后面使用了一个 OSR(On-Stack Replacement )，是一种在运行时替换正在运行的函数/方法的栈帧的技术。
         * 会对代码进行优化
         */
        // 使用两个线程
        new Thread(() -> {
            ArrayList<Integer> list00 = new ArrayList<>();
            long start00 = System.currentTimeMillis();
            for (int i = 0; i < 10000000; i++) {
                list00.add(i);
            }
            System.out.println(System.currentTimeMillis() - start00);
        }).start();

        new Thread(() -> {
            ArrayList<Integer> list01 = new ArrayList<>();
            long start01 = System.currentTimeMillis();
            for (int i = 0; i < 10000000; i++) {
                list01.add(i);
            }
            System.out.println(System.currentTimeMillis() - start01);
        }).start();

        // 当开启两个线程之后，两者的时间几乎一致
    }
}
```
　　添加虚拟机参数`-XX:+PrintGCDetails -XX:+PrintGCDateStamps`
　　通过使用此案例来理解GC日志。  

```Java
2020-09-29T14:37:03.221+0800: [GC (Allocation Failure) [PSYoungGen: 33280K->5108K(38400K)] 33280K->21340K(125952K), 0.0365268 secs] [Times: user=0.13 sys=0.00, real=0.04 secs] 
2020-09-29T14:37:03.267+0800: [GC (Allocation Failure) [PSYoungGen: 38388K->5096K(71680K)] 54620K->42787K(159232K), 0.0431592 secs] [Times: user=0.09 sys=0.00, real=0.04 secs] 
2020-09-29T14:37:03.326+0800: [GC (Allocation Failure) [PSYoungGen: 55279K->5096K(71680K)] 92970K->91779K(159232K), 0.0954035 secs] [Times: user=0.19 sys=0.03, real=0.10 secs] 
2020-09-29T14:37:03.421+0800: [Full GC (Ergonomics) [PSYoungGen: 5096K->0K(71680K)] [ParOldGen: 86683K->80905K(190464K)] 91779K->80905K(262144K), [Metaspace: 3498K->3498K(1056768K)], 0.9455541 secs] [Times: user=1.22 sys=0.03, real=0.95 secs] 
2020-09-29T14:37:04.426+0800: [GC (Allocation Failure) [PSYoungGen: 66560K->5120K(104960K)] 183520K->157952K(295424K), 0.1566299 secs] [Times: user=0.16 sys=0.06, real=0.16 secs] 
2020-09-29T14:37:04.583+0800: [Full GC (Ergonomics) [PSYoungGen: 5120K->0K(104960K)] [ParOldGen: 152832K->141795K(300544K)] 157952K->141795K(405504K), [Metaspace: 3998K->3998K(1056768K)], 1.1007526 secs] [Times: user=1.38 sys=0.03, real=1.10 secs] 
2020-09-29T14:37:05.709+0800: [GC (Allocation Failure) [PSYoungGen: 99840K->5120K(138240K)] 241635K->239742K(438784K), 0.1440980 secs] [Times: user=0.38 sys=0.05, real=0.14 secs] 
2020-09-29T14:37:05.853+0800: [Full GC (Ergonomics) [PSYoungGen: 5120K->0K(138240K)] [ParOldGen: 234622K->203542K(454144K)] 239742K->203542K(592384K), [Metaspace: 3998K->3998K(1056768K)], 1.3979573 secs] [Times: user=2.09 sys=0.00, real=1.40 secs] 
4056
2020-09-29T14:37:07.289+0800: [GC (Allocation Failure) [PSYoungGen: 120885K->95217K(210944K)] 324428K->307607K(665088K), 0.1077882 secs] [Times: user=0.30 sys=0.08, real=0.11 secs] 
2020-09-29T14:37:07.419+0800: [GC (Allocation Failure) [PSYoungGen: 210929K->119287K(235008K)] 423319K->367325K(689152K), 0.1829729 secs] [Times: user=0.42 sys=0.09, real=0.18 secs] 
366
Heap
 PSYoungGen      total 235008K, used 212303K [0x00000000d5d00000, 0x00000000f3900000, 0x0000000100000000)
  eden space 115712K, 80% used [0x00000000d5d00000,0x00000000db7d6000,0x00000000dce00000)
  from space 119296K, 99% used [0x00000000dce00000,0x00000000e427dc60,0x00000000e4280000)
  to   space 159232K, 0% used [0x00000000e9d80000,0x00000000e9d80000,0x00000000f3900000)
 ParOldGen       total 454144K, used 248038K [0x0000000081600000, 0x000000009d180000, 0x00000000d5d00000)
  object space 454144K, 54% used [0x0000000081600000,0x0000000090839aa0,0x000000009d180000)
 Metaspace       used 4008K, capacity 4572K, committed 4864K, reserved 1056768K
  class space    used 447K, capacity 460K, committed 512K, reserved 1048576K
```
　　如上所示:`2020-09-29T14:37:03.221+0800:`，代表的是GC发生的时间，这个数字的含义是从Java虚拟机启动以来经过的秒数。但是在这里是使用了时间的一个格式来显示的。  
　　
  GC的日志开头“`[GC`”和“`[Full GC`”说明这个垃圾收集的**停顿类型**，而不是用来区分新生代GC还是老年代GC的。如果有“Full”，说明这次GC是发生了Stop-The-World的。例如下面这段新生代收集器ParNew的日志也会出现“`[Full GC`”（这一般是因为出现了分配担保失败之类的问题，所以才导致STW）。如果是调用System.gc()方法所触发的收集，那么在这里将显示“`[Full GC(System)`”。  
　　
　　`［Full GC 283.736:  [ParNew:  261599K->261599K(261952K), 0.0000288 secs]`  
　　
  接下来的“[DefNew”、“[Tenured”、“[Perm”表示GC发生的区域，这里显示的区域名称与使用的GC收集器是密切相关的，例如上面样例使用的Serial收集器中的新生代名为“Default New Generation”，所以显示的是“[DefNew”。如果是ParNew收集器，新生代名称就会变为“[ParNew”，意为“Parallel New Generation”。如果采用Parallel Scavenge收集器，那它配套的新生代称为“PSYongGen”，老年代和永久代同理，名称也是由收集器决定的。  
　　
　以这个为例：`2020-09-29T14:37:03.221+0800: [GC (Allocation Failure) [PSYoungGen: 33280K->5108K(38400K)] 33280K->21340K(125952K), 0.0365268 secs] [Times: user=0.13 sys=0.00, real=0.04 secs] `。  
　　
　后面一部分方括号内部的`33280K->5108K(38400K)`，含义是“GC前该内存区域已使用量->GC后该内存区域已使用量（该内存区域总容量）”。而在方括号外部的`33280K->21340K(125952K)`表示“GC前Java堆已使用容量 -> GC后Java堆已使用容量（Java堆总量量）”。  
　　
　再往后“0.0365268 secs”表示该内存区域GC所占用的时间，单位是秒。有的收集器会给出更具体的时间数据，如跟在后面的方括号里面的内容：“[Times: user=0.13 sys=0.00, real=0.04 secs]”，分别代表**用户态消耗的CPU时间**、**内核态消耗的CPU时间**和**操作从开始到结束所经过的墙钟时间（Wall Clock Time）**。CPU时间与墙钟时间的区别是：墙钟时间包括各种**非运算的等待耗时，例如等待磁盘IO、等待线程阻塞**，而**CPU时间不包括这些耗时，但当系统有多CPU或者多核的话，多线程操作会叠加这些CPU时间**，所以user或sys超过real时间是完全正常的。  
　　
