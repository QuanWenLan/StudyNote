### 7 并行处理数据与性能

#### 7.1 并行流

并行流就是一个把内容分成多个数据块，并用不同的线程分别处理每个数据块的流。这样一来，你就可以自动把给定操作的工作负荷分配给多核处理器的所有内核，让它们都忙起来。

假设你需要写一个方法，接受数字n作为参数，并返回从1到给定参数的所有数字的和。一个直接（也许有点土）的方法是生成一个无穷大的数字流，把它限制到给定的数目，然后用对两个数字求和的BinaryOperator来归约这个流，如下所示： 

```java
public static long sequentialSum(long n) {
    return Stream.iterate(1L, i -> i + 1).limit(n).reduce(Long::sum).get();
}
// 传统写法
public static long iterativeSum(long n) {
    long result = 0;
    for (long i = 0; i <= n; i++) {
        result += i;
    }
    return result;
}
```

##### 7.1.1 将顺序流转换为并行流 

```java
public static long parallelSum(long n) {
    return Stream.iterate(1L, i -> i + 1).limit(n).parallel().reduce(Long::sum).get();
}
```

不同之处在于Stream在内部分成了几块。因此可以对不同的块独立并行进行归纳操作，如图7-1所示。最后，同一个归纳操作会将各个子流的部分归纳结果合并起来，得到整个原始流的归纳结果。 

![image-20240105120650334](media/images/image-20240105120650334.png)

请注意，在现实中，对顺序流调用parallel方法并不意味着流本身有任何实际的变化。它在内部实际上就是设了一个boolean标志，表示你想让调用parallel之后进行的所有操作都并行执行。类似地，你只需要对并行流调用sequential方法就可以把它变成顺序流。请注意，你可能以为把这两个方法结合起来，就可以更细化地控制在遍历流时哪些操作要并行执行，哪些要顺序执行。例如，你可以这样做： 

```java
stream.parallel() 
      .filter(...) 
      .sequential() 
      .map(...) 
      .parallel() 
      .reduce();
```

但最后一次parallel或sequential调用会影响整个流水线。在本例中，流水线会并行执行，因为最后调用的是它。 

> 并行流内部使用了默认的ForkJoinPool（7.2节会进一步讲到分支/合并框架），它默认的线 程 数 量 就 是 你 的 处 理 器 数 量 ， 这 个 值 是 由 Runtime.getRuntime().available- Processors()得到的。 但 是 你 可 以 通 过 系 统 属 性 java.util.concurrent.ForkJoinPool.common. parallelism来改变线程池大小，如下所示：System.setProperty("java.util.concurrent.ForkJoinPool.common.parallelism","12"); 这是一个全局设置，因此它将影响代码中所有的并行流。反过来说，目前还无法专为某个并行流指定这个值。一般而言，让ForkJoinPool的大小等于处理器数量是个不错的默认值，除非你有很好的理由，否则我们强烈建议你不要修改它。

测试性能：

```java
public static void main(String[] args) {
    System.out.println("Iterative Sum done in: " + measurePerf(ParallelStreams::iterativeSum, 10_000_000L) + " msecs");
    System.out.println("Sequential Sum done in: " + measurePerf(ParallelStreams::sequentialSum, 10_000_000L) + " msecs");
    System.out.println("Parallel forkJoinSum done in: " + measurePerf(ParallelStreams::parallelSum, 10_000_000L) + " msecs" );
}

public static <T, R> long measurePerf(Function<T, R> f, T input) {
    long fastest = Long.MAX_VALUE;
    for (int i = 0; i < 10; i++) {
        long start = System.nanoTime();
        R result = f.apply(input);
        long duration = (System.nanoTime() - start) / 1_000_000;
        System.out.println("Result: " + result);
        if (duration < fastest) fastest = duration;
    }
    return fastest;
}
```

输出：

```tex
Iterative Sum done in: 2 msecs
Sequential Sum done in: 63 msecs
Parallel forkJoinSum done in: 107 msecs
```

这相当令人失望，求和方法的并行版本比顺序版本要慢很多。你如何解释这个意外的结果呢？这里实际上有两个问题： 

- iterate生成的是装箱的对象，必须拆箱成数字才能求和； 
- 我们很难把iterate分成多个独立块来并行执行。

第二个问题更有意思一点，因为你必须意识到某些流操作比其他操作更容易并行化。具体来说，iterate很难分割成能够独立执行的小块，因为每次应用这个函数都要依赖前一次应用的结果，如图7-2所示。

![image-20240105122429749](media/images/image-20240105122429749.png)

这意味着，在这个特定情况下，归纳进程不是像图7-1那样进行的；**整张数字列表在归纳过程开始时没有准备好，因而无法有效地把流划分为小块来并行处理**。**把流标记成并行，你其实是给顺序处理增加了开销，它还要把每次求和操作分到一个不同的线程上**。 

这就说明了并行编程可能很复杂，有时候甚至有点违反直觉。如果用得不对（比如采用了一个不易并行化的操作，如iterate），它甚至可能让程序的整体性能更差，所以**在调用那个看似神奇的parallel操作时，了解背后到底发生了什么是很有必要的**。 

###### 使用更有针对性的方法 

我们在第5章中讨论了一个叫LongStream.rangeClosed的方法。这个方法与iterate相比有两个优点。 

- LongStream.rangeClosed直接产生原始类型的long数字，没有装箱拆箱的开销。 

- LongStream.rangeClosed会生成数字范围，很容易拆分为独立的小块。例如，范围1~20可分为1~5、6~10、11~15和16~20。 

让我们先看一下它用于顺序流时的性能如何，看看拆箱的开销到底要不要紧： 

```java
public static long rangedSum(long n) {
    return LongStream.rangeClosed(1, n).reduce(Long::sum).getAsLong();
}
```

输出：Range forkJoinSum done in: 10 msecs



