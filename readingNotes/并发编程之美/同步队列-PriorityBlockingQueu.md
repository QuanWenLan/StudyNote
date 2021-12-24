###  PriorityBlockingQueue原理探究

#### 1 介绍

**PriorityBlockingQueue是带优先级的无界阻塞队列，每次出队都返回优先级最高或者最低的元素**。其**内部是使用平衡二叉树堆实现的，所以直接遍历队列元素不保证有序**。默认使用对象的compareTo方法提供比较规则，如果你需要自定义比较规则则可以自定义comparators。