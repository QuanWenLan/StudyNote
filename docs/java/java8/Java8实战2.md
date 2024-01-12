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

##### 7.1.2 测试性能：

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

- **iterate生成的是装箱的对象，必须拆箱成数字才能求和**； 
- **我们很难把iterate分成多个独立块来并行执行**。

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

输出：Range forkJoinSum done in: 10 msecs，我这里执行比 Iterative 要慢一点。但是比Parallel的还是快的。

```java
System.out.println("Parallel range forkJoinSum done in: " + measurePerf(ParallelStreams::parallelRangedSum, 10_000_000L) + " msecs" );

 public static long parallelRangedSum(long n) {
     return LongStream.rangeClosed(1, n).parallel().reduce(Long::sum).getAsLong();
 }
```

输出：Parallel range forkJoinSum done in: 1 msecs

终于，我们得到了一个比顺序执行更快的并行归纳，因为这一次归纳操作可以像图7-1那样执行了。这也表明，使用正确的数据结构然后使其并行工作能够保证最佳的性能。

管如此，请记住，并行化并不是没有代价的。并行化过程本身需要对流做递归划分，把每个子流的归纳操作分配到不同的线程，然后把这些操作的结果合并成一个值。但在多个内核之间移动数据的代价也可能比你想的要大，所以很重要的一点是要保证在内核中并行执行工作的时间比在内核之间传输数据的时间长。总而言之，很多情况下不可能或不方便并行化。然而，在使用并行Stream加速代码之前，你必须确保用得对；如果结果错了，算得快就毫无意义了。

##### 7.1.3 正确使用并行流

错用并行流而产生错误的首要原因，就是使用的算法改变了某些共享状态。下面是另一种实现对前n个自然数求和的方法，**但这会改变一个共享累加器**： 

```java
public static long sideEffectSum(long n) {
    Accumulator accumulator = new Accumulator();
    LongStream.rangeClosed(1, n).forEach(accumulator::add);
    return accumulator.total;
}
public static class Accumulator {
    private long total = 0;

    public void add(long value) {
        total += value;
    }
}
```

初始化一个累加器，一个个遍历列表中的元素，把它们和累加器相加。 

那这种代码又有什么问题呢？不幸的是，它真的无可救药，因为**它在本质上就是顺序的**。**每次访问total都会出现数据竞争**。**如果你尝试用同步来修复，那就完全失去并行的意义了**。为了说明这一点，让我们试着把Stream变成并行的： 

```java
public static long sideEffectParallelSum(long n) {
    Accumulator accumulator = new Accumulator();
    LongStream.rangeClosed(1, n).parallel().forEach(accumulator::add);
    return accumulator.total;
}
System.out.println("SideEffect prallel sum done in: " + measurePerf(ParallelStreams::sideEffectParallelSum, 10_000_000L) + " msecs" );
```

执行结果：计算结果是错误的。

```tex
Result: 5292399724712
Result: 4307030171449
Result: 3463022211990
Result: 3362504015420
Result: 4502867439029
Result: 3778954813429
Result: 2893058098100
Result: 3351972252034
Result: 3819702291578
Result: 4305879175474
SideEffect prallel sum done in: 37 msecs

Process finished with exit code 0
```

这回方法的性能无关紧要了，唯一要紧的是每次执行都会返回不同的结果，都离正确值50000005000000差很远。这是由于多个线程在同时访问累加器，执行total += value，而这一句虽然看似简单，却不是一个原子操作。问题的根源在于，forEach中调用的方法有副作用，它会改变多个线程共享的对象的可变状态。要是你想用并行Stream又不想引发类似的意外，就必须避免这种情况。

**避免使用线程不安全的代码**。

##### 7.1.4 高效使用并行流

- 留意装箱。自动装箱和拆箱操作会大大降低性能。Java 8中有原始类型流（IntStream、LongStream、DoubleStream）来避免这种操作，但凡有可能都应该用这些流。
- 有些操作本身在并行流上的性能就比顺序流差。特别是limit和findFirst等依赖于元素顺序的操作，它们在并行流上执行的代价非常大。例如，findAny会比findFirst性能好，因为它不一定要按顺序来执行。你总是可以调用unordered方法来把有序流变成无序流。那么，如果你需要流中的n个元素而不是专门要前n个的话，对无序并行流调用limit可能会比单个有序流（比如数据源是一个List）更高效。
- 还要考虑流的操作流水线的总计算成本。设N是要处理的元素的总数，Q是一个元素通过流水线的大致处理成本，则N*Q就是这个对成本的一个粗略的定性估计。Q值较高就意味着使用并行流时性能好的可能性比较大。
- 对于较小的数据量，选择并行流几乎从来都不是一个好的决定。并行处理少数几个元素的好处还抵不上并行化造成的额外开销。
- 要考虑流背后的数据结构是否易于分解。例如，ArrayList的拆分效率比LinkedList高得多，因为前者用不着遍历就可以平均拆分，而后者则必须遍历。另外，用range工厂方法创建的原始类型流也可以快速分解。
- 流自身的特点，以及流水线中的中间操作修改流的方式，都可能会改变分解过程的性能。例如，一个SIZED流可以分成大小相等的两部分，这样每个部分都可以比较高效地并行处理，但筛选操作可能丢弃的元素个数却无法预测，导致流本身的大小未知。 
- 还要考虑终端操作中合并步骤的代价是大是小（例如Collector中的combiner方法）。如果这一步代价很大，那么组合每个子流产生的部分结果所付出的代价就可能会超出通过并行流得到的性能提升。

表7-1按照可分解性总结了一些流数据源适不适于并行。

![image-20240110172153588](media/images/image-20240110172153588.png)

#### 7.2 分支/合并框架

**分支/合并框架的目的是以递归方式将可以并行的任务拆分成更小的任务，然后将每个子任务的结果合并起来生成整体结果**。它是ExecutorService接口的一个实现，它把子任务分配给线程池（称为ForkJoinPool）中的工作线程。首先来看看如何定义任务和子任务。 

##### 7.2.1 使用RecursiveTask 

要把任务提交到这个池，必须创建RecursiveTask<R>的一个子类，其中R是并行化任务（以及所有子任务）产生的结果类型，或者如果任务不返回结果，则是RecursiveAction类型（当然它可能会更新其他非局部机构）。要定义RecursiveTask，只需实现它唯一的抽象方法compute：

```java
protected abstract V compute();
```

这个方法**同时定义了将任务拆分成子任务的逻辑，以及无法再拆分或不方便再拆分时，生成单个子任务结果的逻辑**。正由于此，这个方法的实现类似于下面的伪代码： 

```java
if (任务足够小或不可分) { 
    顺序计算该任务  
} else { 
    将任务分成两个子任务 
    递归调用本方法，拆分每个子任务，等待所有子任务完成 
    合并每个子任务的结果 
} 
```

一般来说并没有确切的标准决定一个任务是否应该再拆分，但有几种试探方法可以帮助你做出这一决定。递归的任务拆分过程如图7-3所示：

![image-20240110173059187](media/images/image-20240110173059187.png)

实际的例子

```java
import java.util.concurrent.RecursiveTask;
import java.util.concurrent.ForkJoinTask;
import java.util.stream.LongStream;

import static com.lanwq.java8.inaction.chapter7.ParallelStreamsHarness.FORK_JOIN_POOL;

/**
 * 继承 RecursiveTask 来创建可以用于分支/合并框架的任务
 */
public class ForkJoinSumCalculator extends RecursiveTask<Long> {

    /**
     * 不再将任务分解为子任务的数组大小
     */
    public static final long THRESHOLD = 10_000;

    /**
     * 求和的数组
     */
    private final long[] numbers;
    /**
     * 起始和结束位置
     */
    private final int start;
    private final int end;

    public ForkJoinSumCalculator(long[] numbers) {
        this(numbers, 0, numbers.length);
    }

    /**
     * 私有构造用于以递归方式为主任务创建子任务
     * @param numbers
     * @param start
     * @param end
     */
    private ForkJoinSumCalculator(long[] numbers, int start, int end) {
        this.numbers = numbers;
        this.start = start;
        this.end = end;
    }

    /**
     * 覆盖 RecursiveTask 抽象方法
     * @return
     */
    @Override
    protected Long compute() {
        int length = end - start;
        // 如果大小小于或等于阈值，顺序计算结果
        if (length <= THRESHOLD) {
            return computeSequentially();
        }
        // 创建一个子任务来为数组的前一半求和
        ForkJoinSumCalculator leftTask = new ForkJoinSumCalculator(numbers, start, start + length/2);
        // 利用另一个ForkJoinPool线程异步执行新创建的子任务
        leftTask.fork();
        // 创建一个子任务来为数组的后一半求和
        ForkJoinSumCalculator rightTask = new ForkJoinSumCalculator(numbers, start + length/2, end);
        // 同步执行第二个子任务，有可能允许进一步递归划分
        Long rightResult = rightTask.compute();
        // 读取第一个子任务的结果，如果尚未完成就等待
        Long leftResult = leftTask.join();
        return leftResult + rightResult;
    }

    /**
     * 在子任务在不可分时计算结果的算法
     * @return
     */
    private long computeSequentially() {
        long sum = 0;
        for (int i = start; i < end; i++) {
            sum += numbers[i];
        }
        return sum;
    }

    public static long forkJoinSum(long n) {
        long[] numbers = LongStream.rangeClosed(1, n).toArray();
        ForkJoinTask<Long> task = new ForkJoinSumCalculator(numbers);
        return FORK_JOIN_POOL.invoke(task);
    }
}
public static final ForkJoinPool FORK_JOIN_POOL = new ForkJoinPool();
// 调用
System.out.println("ForkJoin sum done in: " + measurePerf(ForkJoinSumCalculator::forkJoinSum, 10_000_000L) + " msecs" );
// ForkJoin sum done in: 29 msecs
```

请注意在实际应用时，使用多个ForkJoinPool是没有什么意义的。正是出于这个原因，一般来说把它实例化一次，然后把实例保存在静态字段中，使之成为单例，这样就可以在软件中任何部分方便地重用了。这里创建时用了其默认的无参数构造函数，这意味着想让线程池使用JVM能够使用的所有处理器。更确切地说，该构造函数将使用Runtime.availableProcessors的返回值来决定线程池使用的线程数。请注意availableProcessors方法虽然看起来是处理器，但它实际上返回的是可用内核的数量，包括超线程生成的虚拟内核。

**运行ForkJoinSumCalculator**

**当把ForkJoinSumCalculator任务传给ForkJoinPool时，这个任务就由池中的一个线程执行，这个线程会调用任务的compute方法**。**该方法会检查任务是否小到足以顺序执行，如果不够小则会把要求和的数组分成两半，分给两个新的ForkJoinSumCalculator，而它们也由ForkJoinPool安排执行**。因此，这一过程可以递归重复，把原任务分为更小的任务，直到满足不方便或不可能再进一步拆分的条件（本例中是求和的项目数小于等于10 000）。这时会顺序计算每个任务的结果，然后由分支过程创建的（隐含的）任务二叉树遍历回到它的根。接下来会合并每个子任务的部分结果，从而得到总任务的结果。这一过程如图7-4所示。 

![image-20240111090805869](media/images/image-20240111090805869.png)

这个性能看起来比用并行流的版本要差，但这只是因为必须先要把整个数字流都放进一个long[]，之后才能在ForkJoinSumCalculator任务中使用它。

##### 7.2.2 使用分支/合并框架的最佳做法 

- **对一个任务调用join方法会阻塞调用方，直到该任务做出结果**。因此，有必要在两个子任务的计算都开始之后再调用它。否则，你得到的版本会比原始的顺序算法更慢更复杂，因为每个子任务都必须等待另一个子任务完成才能启动。
- 不应该在RecursiveTask内部使用ForkJoinPool的invoke方法。相反，你应该始终直接调用compute或fork方法，只有顺序代码才应该用invoke来启动并行计算。 
- **对子任务调用fork方法可以把它排进ForkJoinPool**。**同时对左边和右边的子任务调用它似乎很自然，但这样做的效率要比直接对其中一个调用compute低**。这样做你可以为其中一个子任务重用同一线程，从而避免在线程池中多分配一个任务造成的开销。
- **调试使用分支/合并框架的并行计算可能有点棘手**。特别是你平常都在你喜欢的IDE里面看栈跟踪（stack trace）来找问题，但放在分支-合并计算上就不行了，因为调用compute的线程并不是概念上的调用方，后者是调用fork的那个。 
- **和并行流一样，你不应理所当然地认为在多核处理器上使用分支/合并框架就比顺序计算快**。我们已经说过，**一个任务可以分解成多个独立的子任务，才能让性能在并行化时有所提升**。所有这些子任务的运行时间都应该比分出新任务所花的时间长；一个惯用方法是把输入/输出放在一个子任务里，计算放在另一个里，这样计算就可以和输入/输出同时进行。此外，在比较同一算法的顺序和并行版本的性能时还有别的因素要考虑。就像任何其他Java代码一样，分支/合并框架需要“预热”或者说要执行几遍才会被JIT编译器优化。这就是为什么在测量性能之前跑几遍程序很重要，我们的测试框架就是这么做的。同时还要知道，编译器内置的优化可能会为顺序版本带来一些优势（例如执行死码分析——删去从未被使用的计算）。

**你必须选择一个标准，来决定任务是要进一步拆分还是已小到可以顺序求值**。

##### 7.2.3 工作窃取

在ForkJoinSumCalculator的例子中，我们决定在要求和的数组中最多包含10 000个项目时就不再创建子任务了。这个选择是很随意的，但大多数情况下也很难找到一个好的启发式方法来确定它，只能试几个不同的值来尝试优化它。在我们的测试案例中，我们先用了一个有1000万项目的数组，意味着ForkJoinSumCalculator至少会分出1000个子任务来。这似乎有点浪费资源，因为我们用来运行它的机器上只有四个内核。在这个特定例子中可能确实是这样，因为所有的任务都受CPU约束，预计所花的时间也差不多。 

但分出大量的小任务一般来说都是一个好的选择。这是因为，理想情况下，划分并行任务时，应该让每个任务都用完全相同的时间完成，让所有的CPU内核都同样繁忙。不幸的是，实际中，每个子任务所花的时间可能天差地别，要么是因为划分策略效率低，要么是有不可预知的原因，比如磁盘访问慢，或是需要和外部服务协调执行。 

**分支/合并框架工程用一种称为工作窃取（work stealing）的技术来解决这个问题**。在实际应用中，这意味着**这些任务差不多被平均分配到ForkJoinPool中的所有线程上**。**每个线程都为分配给它的任务保存一个双向链式队列，每完成一个任务，就会从队列头上取出下一个任务开始执行**。基于前面所述的原因，某个线程可能早早完成了分配给它的所有任务，也就是它的队列已经空了，而其他的线程还很忙。这时，这个线程并没有闲下来，而是随机选了一个别的线程，从队列的尾巴上“偷走”一个任务。这个过程一直继续下去，直到所有的任务都执行完毕，所有的队列都清空。这就是为什么要划成许多小任务而不是少数几个大任务，这有助于更好地在工作线程之间平衡负载。 

一般来说，这种工作窃取算法用于在池中的工作线程之间重新分配和平衡任务。图7-5展示了这个过程。当工作线程队列中有一个任务被分成两个子任务时，一个子任务就被闲置的工作线程“偷走”了。如前所述，这个过程可以不断递归，直到规定子任务应顺序执行的条件为真。

![image-20240111092518441](media/images/image-20240111092518441.png)

#### 7.3 Spliterator

Spliterator是Java 8中加入的另一个新接口；**这个名字代表“可分迭代器”（splitable iterator）**。**和Iterator一样，Spliterator也用于遍历数据源中的元素，但它是为了并行执行而设计的**。虽然在实践中可能用不着自己开发Spliterator，但了解一下它的实现方式会让你对并行流的工作原理有更深入的了解。Java 8已经为集合框架中包含的所有数据结构提供了一个默认的Spliterator实现。集合实现了Spliterator接口，接口提供了一个spliterator方法。这个接口定义了若干方法，如下面的代码清单所示。 

![image-20240111092949271](media/images/image-20240111092949271.png)

与往常一样，T是Spliterator遍历的元素的类型。tryAdvance方法的行为类似于普通的Iterator，因为它会按顺序一个一个使用Spliterator中的元素，并且如果还有其他元素要遍历就返回true。**但trySplit是专为Spliterator接口设计的，因为它可以把一些元素划出去分给第二个Spliterator（由该方法返回），让它们两个并行处理。Spliterator还可通过estimateSize方法估计还剩下多少元素要遍历，因为即使不那么确切，能快速算出来是一个值也有助于让拆分均匀一点**。 

##### 7.3.1 拆分过程

将Stream拆分成多个部分的算法是一个递归过程，如图7-6所示。第一步是对第一个Spliterator调用trySplit，生成第二个Spliterator。第二步对这两个Spliterator调用trysplit，这样总共就有了四个Spliterator。这个框架不断对Spliterator调用trySplit直到它返回null，表明它处理的数据结构不能再分割，如第三步所示。最后，这个递归拆分过程到第四步就终止了，这时所有的Spliterator在调用trySplit时都返回了null。 

![image-20240111093554612](media/images/image-20240111093554612.png)

这个拆分过程也受Spliterator本身的特性影响，而特性是通过characteristics方法声明的。 

###### Spliterator的特性 

Spliterator接口声明的最后一个抽象方法是characteristics，它将返回一个int，代表Spliterator本身特性集的编码。使用Spliterator的客户可以用这些特性来更好地控制和优化它的使用。表7-2总结了这些特性。（不幸的是，虽然它们在概念上与收集器的特性有重叠，编码却不一样。） 

![image-20240111093713516](media/images/image-20240111093713516.png)

##### 7.3.2 实现自定义的 Spliterator

我们要开发一个简单的方法来数数一个String中的单词数。这个方法的一个迭代版本可以写成下面的样子。

```java
public int countWordsIteratively(String s) { 
    int counter = 0; 
    boolean lastSpace = true; 
    for (char c : s.toCharArray()) {  
        if (Character.isWhitespace(c)) { 
            lastSpace = true; 
        } else { 
            // 上一个字符是空格，而当前遍历的字符不是空格时，将单词计数器加一 
            if (lastSpace) counter++;  
            lastSpace = false; 
        } 
    } 
    return counter; 
} 
```

测试：

```java
final String SENTENCE = 
            " Nel   mezzo del cammin  di nostra  vita " + 
            "mi  ritrovai in una  selva oscura" + 
            " ché la  dritta via era   smarrita "; 
 
System.out.println("Found " + countWordsIteratively(SENTENCE) + " words"); 
// Found 19 words
```

###### 1 以函数式风格重写单词计数器

首先你需要把String转换成一个流。不幸的是，原始类型的流仅限于int、long和double，所以你只能用Stream<Character>：

```java
Stream<Character> stream = IntStream.range(0, SENTENCE.length()) 
                                    .mapToObj(SENTENCE::charAt);
```

你可以对这个流做归约来计算字数。在归约流时，你得保留由两个变量组成的状态：一个int用来计算到目前为止数过的字数，还有一个boolean用来记得上一个遇到的Character是不是空格。

用来在遍历Character流时计数的类

```java
private static class WordCounter {
    private final int counter;
    private final boolean lastSpace;

    public WordCounter(int counter, boolean lastSpace) {
        this.counter = counter;
        this.lastSpace = lastSpace;
    }

    public WordCounter accumulate(Character c) {
        // 和迭代算法一样，accumulate方法一个个遍历 Character
        if (Character.isWhitespace(c)) {
            return lastSpace ? this : new WordCounter(counter, true);
        } else {
            // 上一个字符是空格，而当前遍历的字符不是空格是，将单词计数器加1
            return lastSpace ? new WordCounter(counter+1, false) : this;
        }
    }

    // 合并两个 wordCounter ，把其计数器加起来
    public WordCounter combine(WordCounter wordCounter) {
        // 仅仅需要计数器的总和，无需关心 lastSpace
        return new WordCounter(counter + wordCounter.counter, wordCounter.lastSpace);
    }

    public int getCounter() {
        return counter;
    }
}
```

图7-7展示了accumulate方法遍历到新的Character时，WordCounter的状态转换。调用第二个方法 combine时，会对作用于Character流的两个不同子部分的两个WordCounter的部分结果进行汇总，也就是把两个WordCounter内部的计数器加起来。

![image-20240111095413786](media/images/image-20240111095413786.png)

```java
private int countWords(Stream<Character> stream) { 
    WordCounter wordCounter = stream.reduce(new WordCounter(0, true), 
                                            WordCounter::accumulate, 
                                            WordCounter::combine); 
    return wordCounter.getCounter(); 
} 
```

测试

```java
Stream<Character> stream = IntStream.range(0, SENTENCE.length()) 
                                    .mapToObj(SENTENCE::charAt); 
System.out.println("Found " + countWords(stream) + " words"); 
// Found 19 words
```

###### 2 让WordCounter并行工作 

```java
System.out.println("Found " + countWords(stream.parallel()) + " words"); 
// 不幸的是，这次的输出是： 
// Found 25 words 
```

显然有什么不对，可到底是哪里不对呢？问题的根源并不难找。因为原始的String在任意位置拆分，所以有时一个词会被分为两个词，然后数了两次。这就说明，拆分流会影响结果，而把顺序流换成并行流就可能使结果出错。 

如何解决这个问题呢？**解决方案就是要确保String不是在随机位置拆开的，而只能在词尾拆开**。要做到这一点，你必须为Character实现一个Spliterator，它只能在两个词之间拆开String（如下所示），然后由此创建并行流。 

```java
private static class WordCounterSpliterator implements Spliterator<Character> {

    private final String string;
    private int currentChar = 0;

    private WordCounterSpliterator(String string) {
        this.string = string;
    }

    @Override
    public boolean tryAdvance(Consumer<? super Character> action) {
        // 处理当前字符
        action.accept(string.charAt(currentChar++));
        // 如果还有字符要处理，则返回true
        return currentChar < string.length();
    }

    @Override
    public Spliterator<Character> trySplit() {
        int currentSize = string.length() - currentChar;
        if (currentSize < 10) {
            // 返回null表示解析的string已经足够小，可以顺序处理
            return null;
        }
        // 将试探拆分位置设定为要解析的string的中间
        for (int splitPos = currentSize / 2 + currentChar; splitPos < string.length(); splitPos++) {
            // 让拆分位置前进知道下一个空格
            if (Character.isWhitespace(string.charAt(splitPos))) {
                // 创建一个新的WordCounterSpliterator来解析string从开始到拆分位置的部分
                Spliterator<Character> spliterator = new WordCounterSpliterator(string.substring(currentChar, splitPos));
                // 将这个WordCounter-Spliterator的起始位置设为拆分位置
                currentChar = splitPos;
                return spliterator;
            }
        }
        return null;
    }

    @Override
    public long estimateSize() {
        return string.length() - currentChar;
    }

    @Override
    public int characteristics() {
        return ORDERED + SIZED + SUBSIZED + NONNULL + IMMUTABLE;
    }
}
```

- tryAdvance方法把String中当前位置的Character传给了Consumer，并让位置加一。作为参数传递的Consumer是一个Java内部类，在遍历流时将要处理的Character传给了一系列要对其执行的函数。这里只有一个归约函数，即WordCounter类的accumulate方 法 。 如 果 新 的 指 针 位 置 小 于 String的 总 长 ， 且 还 有 要 遍 历 的 Character， 则tryAdvance返回true。
- trySplit方法是Spliterator中最重要的一个方法，因为它定义了拆分要遍历的数据结构的逻辑。就像在代码清单7-1中实现的RecursiveTask的compute方法一样（分支/合并框架的使用方式），首先要设定不再进一步拆分的下限。这里用了一个非常低的下限——10个Character，仅仅是为了保证程序会对那个比较短的String做几次拆分。在实际应用中，就像分支/合并的例子那样，你肯定要用更高的下限来避免生成太多的
  任务。如果剩余的Character数量低于下限，你就返回null表示无需进一步拆分。相反，如果你需要执行拆分，就把试探的拆分位置设在要解析的String块的中间。但我们没有直接使用这个拆分位置，因为要避免把词在中间断开，于是就往前找，直到找到一个空格。一旦找到了适当的拆分位置，就可以创建一个新的Spliterator来遍历从当前位置到拆分位置的子串；把当前位置this设为拆分位置，因为之前的部分将由新Spliterator来处理，最后返回。
- 还需要遍历的元素的estimatedSize就是这个Spliterator解析的String的总长度和当前遍历的位置的差。 
- 最后，characteristic方法告诉框架这个Spliterator是ORDERED（顺序就是String中 各 个 Character的 次 序 ）、 SIZED（ estimatedSize方 法 的 返 回 值 是 精 确 的 ）、SUBSIZED（trySplit方法创建的其他Spliterator也有确切大小）、NONNULL（String中 不 能 有 为 null的 Character） 和 IMMUTABLE（ 在 解 析 String时 不 能 再 添 加Character，因为String本身是一个不可变类）的。

哈哈，有点复杂。

###### 3 运用WordCounterSpliterator

```java
Spliterator<Character> spliterator = new WordCounterSpliterator(SENTENCE); 
Stream<Character> stream = StreamSupport.stream(spliterator, true); 
```

传给StreamSupport.stream工厂方法的第二个布尔参数意味着你想创建一个并行流。把这个并行流传给countWords方法： 

```java
System.out.println("Found " + countWords(stream) + " words"); 
//Found 19 words 
```

你已经看到了Spliterator如何让你控制拆分数据结构的策略。Spliterator还有最后一个值得注意的功能，就是可以在第一次遍历、第一次拆分或第一次查询估计大小时绑定元素的数据源，而不是在创建时就绑定。这种情况下，它称为延迟绑定（late-binding）的Spliterator。

#### 8 重构、测试和调试

##### 2 重构设计模式

###### 2.1 策略模式

策略模式代表了解决一类算法的通用解决方案，你可以在运行时选择使用哪种方案。策略模式包含三部分内容，如图8-1所示。

- 一个代表某个算法的接口（它是策略模式的接口）。 
- 一个或多个该接口的具体实现，它们代表了算法的多种实现（比如，实体类Concrete- StrategyA或者ConcreteStrategyB）。 
- 一个或多个使用策略对象的客户。

![image-20240111161938039](media/images/image-20240111161938039.png)

我们假设你希望验证输入的内容是否根据标准进行了恰当的格式化（比如只包含小写字母或数字）。你可以从定义一个验证文本（以String的形式表示）的接口入手：

```java
public interface ValidationStrategy { 
    boolean execute(String s); 
} 
// 其次，你定义了该接口的一个或多个具体实现： 
public class IsAllLowerCase implements ValidationStrategy { 
    public boolean execute(String s){ 
        return s.matches("[a-z]+"); 
    } 
} 
 
public class IsNumeric implements ValidationStrategy { 
    public boolean execute(String s){ 
        return s.matches("\\d+"); 
    } 
} 
```

之后，你就可以在你的程序中使用这些略有差异的验证策略了： 

```java
static private class Validator{
    private final ValidationStrategy strategy;
    public Validator(ValidationStrategy v){
        this.strategy = v;
    }
    public boolean validate(String s){
        return strategy.execute(s); }
}

Validator v1 = new Validator(new IsNumeric());
System.out.println(v1.validate("aaaa"));
Validator v2 = new Validator(new IsAllLowerCase());
System.out.println(v2.validate("bbbb"));
```

**使用Lambda表达式** 

```java
Validator v3 = new Validator((String s) -> s.matches("\\d+"));
System.out.println(v3.validate("aaaa"));
Validator v4 = new Validator((String s) -> s.matches("[a-z]+"));
System.out.println(v4.validate("bbbb"));
```

###### 2.2 模板方法

如果你需要采用某个算法的框架，同时又希望有一定的灵活度，能对它的某些部分进行改进，那么采用模板方法设计模式是比较通用的方案。

假设你需要编写一个简单的在线银行应用。通常，用户需要输入一个用户账户，之后应用才能从银行的数据库中得到用户的详细信息，最终完成一些让用户满意的操作。不同分行的在线银行应用让客户满意的方式可能还略有不同，比如给客户的账户发放红利，或者仅仅是少发送一些推广文件。你可能通过下面的抽象类方式来实现在线银行应用： 

```java
abstract class OnlineBanking {
    public void processCustomer(int id) {
        Customer c = Database.getCustomerWithId(id);
        makeCustomerHappy(c);
    }

    abstract void makeCustomerHappy(Customer c);


    // dummy Customer class
    static private class Customer {
    }

    // dummy Datbase class
    static private class Database {
        static Customer getCustomerWithId(int id) {
            return new Customer();
        }
    }
}
```

processCustomer方法搭建了在线银行算法的框架：获取客户提供的ID，然后提供服务让用户满意。不同的支行可以通过继承OnlineBanking类，对该方法提供差异化的实现。 

**使用Lambda表达式** 

```java
public class OnlineBankingLambda {

    public static void main(String[] args) {
        new OnlineBankingLambda().processCustomer(1337, (Customer c) -> System.out.println("Hello!"));
    }

    public void processCustomer(int id, Consumer<Customer> makeCustomerHappy) {
        Customer c = Database.getCustomerWithId(id);
        makeCustomerHappy.accept(c);
    }

    // dummy Customer class
    static private class Customer {
    }

    // dummy Database class
    static private class Database {
        static Customer getCustomerWithId(int id) {
            return new Customer();
        }
    }
}
```

###### 2.3 观察者模式

观察者模式是一种比较常见的方案，**某些事件发生时（比如状态转变），如果一个对象（通常我们称之为主题）需要自动地通知其他多个对象（称为观察者）**，就会采用该方案。

创建图形用户界面（GUI）程序时，你经常会使用该设计模式。这种情况下，你会在图形用户界面组件（比如按钮）上注册一系列的观察者。如果点击按钮，观察者就会收到通知，并随即执行某个特定的行为。 但是观察者模式并不局限于图形用户界面。比如，观察者设计模式也适用于股票交易的情形，多个券商可能都希望对某一支股票价格（主题）的变动做出响应。图8-2通过UML图解释了观察者模式。 

![image-20240111163242563](media/images/image-20240111163242563.png)

你需要为Twitter这样的应用设计并实现一个定制化的通知系统。想法很简单：好几家报纸机构，比如《纽约时报》《卫报》以及《世界报》都订阅了新闻，他们希望当接收的新闻中包含他们感兴趣的关键字时，能得到特别通知。

首先，你需要一个观察者接口，它将不同的观察者聚合在一起。它仅有一个名为notify的方法，一旦接收到一条新的新闻，该方法就会被调用：

```java
interface Observer {
    void inform(String tweet);
}
```

现在，你可以声明不同的观察者（比如，这里是三家不同的报纸机构），依据新闻中不同的关键字分别定义不同的行为：

```java
static private class NYTimes implements Observer {
    @Override
    public void inform(String tweet) {
        if (tweet != null && tweet.contains("money")) {
            System.out.println("Breaking news in NY!" + tweet);
        }
    }
}

static private class Guardian implements Observer {
    @Override
    public void inform(String tweet) {
        if (tweet != null && tweet.contains("queen")) {
            System.out.println("Yet another news in London... " + tweet);
        }
    }
}

static private class LeMonde implements Observer {
    @Override
    public void inform(String tweet) {
        if (tweet != null && tweet.contains("wine")) {
            System.out.println("Today cheese, wine and news! " + tweet);
        }
    }
}
```

我们遗漏了一个重要的部分：Subject！

```java
interface Subject {
    void registerObserver(Observer o);

    void notifyObservers(String tweet);
}
```

Subject使用registerObserver方法可以注册一个新的观察者，使用notifyObservers方法通知它的观察者一个新闻的到来。让我们更进一步，实现Feed类：

```java
static private class Feed implements Subject {
    private final List<Observer> observers = new ArrayList<>();

    public void registerObserver(Observer o) {
        this.observers.add(o);
    }

    public void notifyObservers(String tweet) {
        observers.forEach(o -> o.inform(tweet));
    }
}
```

运行测试

```java
Feed f = new Feed(); 
f.registerObserver(new NYTimes()); 
f.registerObserver(new Guardian()); 
f.registerObserver(new LeMonde()); 
f.notifyObservers("The queen said her favourite book is Java 8 in Action!");
```

毫不意外，《卫报》会特别关注这条新闻！ 

**使用Lambda表达式**

```java
Feed feedLambda = new Feed();

feedLambda.registerObserver((String tweet) -> {
    if (tweet != null && tweet.contains("money")) {
        System.out.println("Breaking news in NY! " + tweet);
    }
});
feedLambda.registerObserver((String tweet) -> {
    if (tweet != null && tweet.contains("queen")) {
        System.out.println("Yet another news in London... " + tweet);
    }
});

feedLambda.notifyObservers("Money money money, give me money!");
```

那么，是否我们随时随地都可以使用Lambda表达式呢？答案是否定的！我们前文介绍的例子中，Lambda适配得很好，那是因为需要执行的动作都很简单，因此才能很方便地消除僵化代码。但是，观察者的逻辑有可能十分复杂，它们可能还持有状态，抑或定义了多个方法，诸如此类。在这些情形下，你还是应该继续使用类的方式。

###### 2.4 责任链模式

责任链模式是一种创建处理对象序列（比如操作序列）的通用方案。一个处理对象可能需要在完成一些工作之后，将结果传递给另一个对象，这个对象接着做一些工作，再转交给下一个处理对象，以此类推。 

通常，这种模式是通过定义一个代表处理对象的抽象类来实现的，在抽象类中会定义一个字段来记录后续对象。一旦对象完成它的工作，处理对象就会将它的工作转交给它的后继。代码中，这段逻辑看起来是下面这样：

```java
static private abstract class ProcessingObject<T> {
    protected ProcessingObject<T> successor;

    public void setSuccessor(ProcessingObject<T> successor) {
        this.successor = successor;
    }

    public T handle(T input) {
        T r = handleWork(input);
        if (successor != null) {
            return successor.handle(r);
        }
        return r;
    }

    abstract protected T handleWork(T input);
}
```

图8-3以UML的方式阐释了责任链模式。这个是聚合的表示方法。

![image-20240111164053282](media/images/image-20240111164053282.png)

handle方法提供了如何进行工作处理的框架。不同的处理对象可以通过继承ProcessingObject类，提供handleWork方法来进行创建。 

下面让我们看看如何使用该设计模式。你可以创建两个处理对象，它们的功能是进行一些文本处理工作。

```java
static private class HeaderTextProcessing
        extends ProcessingObject<String> {
    public String handleWork(String text) {
        return "From Raoul, Mario and Alan: " + text;
    }
}

static private class SpellCheckerProcessing
        extends ProcessingObject<String> {
    public String handleWork(String text) {
        return text.replaceAll("labda", "lambda");
    }
}
```

现在你就可以将这两个处理对象结合起来，构造一个操作序列！ 

```java
ProcessingObject<String> p1 = new HeaderTextProcessing();
ProcessingObject<String> p2 = new SpellCheckerProcessing();
p1.setSuccessor(p2);
String result1 = p1.handle("Aren't labdas really sexy?!!");
System.out.println(result1);
```

**使用Lambda表达式** 

这个模式看起来像是在链接（也即是构造）函数。你可以将处理对象作为函数的一个实例，或者更确切地说作为UnaryOperator-<String>的一个实例。为了链接这些函数，你需要使用andThen方法对其进行构造。

```java
UnaryOperator<String> headerProcessing =
        (String text) -> "From Raoul, Mario and Alan: " + text;
UnaryOperator<String> spellCheckerProcessing =
        (String text) -> text.replaceAll("labda", "lambda");
Function<String, String> pipeline = headerProcessing.andThen(spellCheckerProcessing);
String result2 = pipeline.apply("Aren't labdas really sexy?!!");
System.out.println(result2);
```

###### 2.5 工厂模式

使用工厂模式，你无需向客户暴露实例化的逻辑就能完成对象的创建。比如，我们假定你为一家银行工作，他们需要一种方式创建不同的金融产品：贷款、期权、股票，等等。 通常，你会创建一个工厂类，它包含一个负责实现不同对象的方法，如下所示： 

```java
public static Product createProduct(String name){
    switch(name){
        case "loan": return new Loan();
        case "stock": return new Stock();
        case "bond": return new Bond();
        default: throw new RuntimeException("No such product " + name);
    }
}

static private interface Product {}
static private class Loan implements Product {}
static private class Stock implements Product {}
static private class Bond implements Product {}
```

使用

```java
Product p1 = ProductFactory.createProduct("loan");
```

**使用Lambda表达式** 

```java
Supplier<Product> loanSupplier = Loan::new;
Product p2 = loanSupplier.get();

Product p3 = ProductFactory.createProductLambda("loan");
```

通过这种方式可以重构之前的代码

```java
final static private Map<String, Supplier<Product>> map = new HashMap<>();
static {
    map.put("loan", Loan::new);
    map.put("stock", Stock::new);
    map.put("bond", Bond::new);
}
static private class ProductFactory {
    public static Product createProductLambda(String name){
        Supplier<Product> p = map.get(name);
        if(p != null) return p.get();
        throw new RuntimeException("No such product " + name);
	}
}
```

这是个全新的尝试，它使用Java 8中的新特性达到了传统工厂模式同样的效果。但是，如果工厂方法createProduct需要接收多个传递给产品构造方法的参数，这种方式的扩展性不是很好。你不得不提供不同的函数接口，无法采用之前统一使用一个简单接口的方式。



##### 4 调试

###### 8.4.1 查看栈跟踪

**Lambda表达式和栈跟踪**

不幸的是，由于Lambda表达式没有名字，它的栈跟踪可能很难分析。在下面这段简单的代码中，我们刻意地引入了一些错误： 

```java
import java.util.*;

public class Debugging {
    public static void main(String[] args) {
        List<Point> points = Arrays.asList(new Point(12, 2), null);
        points.stream().map(p -> p.getX()).forEach(System.out::println);
    }


    private static class Point {
        private int x;
        private int y;

        private Point(int x, int y) {
            this.x = x;
            this.y = y;
        }

        public int getX() {
            return x;
        }

        public void setX(int x) {
            this.x = x;
        }
    }
}
```

这段代码会报错

```java
Exception in thread "main" java.lang.NullPointerException
	at com.lanwq.java8.inaction.chapter8.Debugging.lambda$main$0(Debugging.java:9)
	at java.util.stream.ReferencePipeline$3$1.accept(ReferencePipeline.java:193)
	at java.util.Spliterators$ArraySpliterator.forEachRemaining(Spliterators.java:948)
	at java.util.stream.AbstractPipeline.copyInto(AbstractPipeline.java:481)
	at java.util.stream.AbstractPipeline.wrapAndCopyInto(AbstractPipeline.java:471)
	at java.util.stream.ForEachOps$ForEachOp.evaluateSequential(ForEachOps.java:151)
	at java.util.stream.ForEachOps$ForEachOp$OfRef.evaluateSequential(ForEachOps.java:174)
	at java.util.stream.AbstractPipeline.evaluate(AbstractPipeline.java:234)
	at java.util.stream.ReferencePipeline.forEach(ReferencePipeline.java:418)
	at com.lanwq.java8.inaction.chapter8.Debugging.main(Debugging.java:9)
```

这段程序当然会失败，因为Points列表的第二个元素是空（null）。这时你的程序实际是在试图处理一个空引用。由于Stream流水线发生了错误，构成Stream流水线的整个方法调用序列都暴露在你面前了。

总的来说，我们需要特别注意，涉及Lambda表达式的栈跟踪可能非常难理解。

###### 8.4.2 使用日志调试

一旦调用forEach，整个流就会恢复运行。到底哪种方式能更有效地帮助我们理解Stream流水线中的每个操作（比如map、filter、limit）产生的输出？ 

peek的设计初衷就是在流的每个元素恢复运行之前，插入执行一个动作。但是它不像forEach那样恢复整个流的运行，而是在一个元素上完成操作之后，它只会将操作顺承到流水线中的下一个操作。图8-4解释了peek的操作流程。下面的这段代码中，我们使用peek输出了Stream流水线操作之前和操作之后的中间值：

```java
List<Integer> result = Stream.of(2, 3, 4, 5)
        .peek(x -> System.out.println("taking from stream: " + x)).map(x -> x + 17)
        .peek(x -> System.out.println("after map: " + x)).filter(x -> x % 2 == 0)
        .peek(x -> System.out.println("after filter: " + x)).limit(3)
        .peek(x -> System.out.println("after limit: " + x)).collect(toList());
```

![image-20240111165758065](media/images/image-20240111165758065.png)

通过peek操作我们能清楚地了解流水线操作中每一步的输出结果：

```tex
taking from stream: 2
after map: 19
taking from stream: 3
after map: 20
after filter: 20
after limit: 20
taking from stream: 4
after map: 21
taking from stream: 5
after map: 22
after filter: 22
after limit: 22
```

#### Optional 

[Java 8 的 Optional是个好东西，但你真的用对了吗？](https://blog.csdn.net/qq_34162294/article/details/121134135)
