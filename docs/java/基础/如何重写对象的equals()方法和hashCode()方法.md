#### 如何重写对象的equals()方法和hashCode()方法？

首先这个是参考了博客，[如何重写hashCode()和equals()方法](https://blog.csdn.net/neosmith/article/details/17068365)之后自己的理解。  

- **我们为什么要重写equals方法？**  

　　因为对象的默认的equals方法满足不了当前业务需求的时候。比如：一个对象person拥有两个属性name和age，需求是当这个person的name和age都相等时我们就认为这个是同一个人。这时从Object处继承的equals方法便不能满足我们的要求了。代码如下：  

```Java
public class TestEqualsAndHashCode {
    public static void main(String[] args) {
        Person person1 = new Person("小明", 20);
        Person person2 = new Person("小明", 20);
        System.out.println(person1 == person2); // false
        System.out.println(person1.equals(person2)); // false
    }
    /**
    * object 的equals方法
    public boolean equals(Object obj) {
        return (this == obj); // 比较的是两个引用的地址
    }
    */
}
class Person {
    private String name;
    private int age;

    public Person(String name, int age) {
        this.name = name;
        this.age = age;
    }
    
    public Person() {
    }
}
```

　　为什么是为`false`呢？因为默认是使用的Object的equals方法，比较的是两个对象在Java堆中的地址，而虚拟机遇到new关键字，就会在堆中创建一个对象，两者的地址不相同，所以上面的满足不了我们的要求，这时候就需要重写Object中的equals方法了。  

  - **如何重写equals方法呢？**

    　　如果当决定重写一个对象的equals()方法，那么一定要明确重写之后带来的风险，你重写的equals()方法是不是够健壮、稳定。注意，**在重写equals()方法之后一定要重写hashCode()方法**，因为jdk源码对此有严格的说明：  

    ```Java
    The equals method implements an equivalence relation on non-null object references:
    
    It is reflexive: for any non-null reference value x, x.equals(x) should return true. 
    It is symmetric: for any non-null reference values x and y, x.equals(y) should return true if and only if y.equals(x) returns true.
    It is transitive: for any non-null reference values x, y, and z, if x.equals(y) returns true and y.equals(z) returns true, then x.equals(z) should return true.
    It is consistent: for any non-null reference values x and y, multiple invocations of x.equals(y) consistently return true or consistently return false, provided no information used in equals comparisons on the objects is modified.
    
    For any non-null reference value x, x.equals(null) should return false.
    The equals method for class Object implements the most discriminating possible equivalence relation on objects; that is, for any non-null reference values x and y, this method returns true if and only if x and y refer to the same object (x == y has the value true).
    
    **Note that it is generally necessary to override the hashCode method whenever this method is overridden, so as to maintain the general contract for the hashCode method, which states that equal objects must have equal hash codes**. // 这里就说明了：请注意，无论什么时候equals方法被重写之后，通常都有必要重写hashcode方法，为了维护hashCode方法的通用契约，该契约规定equal对象必须具有相等的哈希码。
    ```
翻译过来的大概意思是：  
    1. 自反性：A.equals(A)要返回true.  
    2. 对称性：如果A.equals(B)返回true, 则B.equals(A)也要返回true.  
    3. 传递性：如果A.equals(B)为true, B.equals(C)为true, 则A.equals(C)也要为true. 说白了就是 A = B , B = C , 那么A = C.  
    4. 一致性：只要A,B对象的状态没有改变，A.equals(B)必须始终返回true.  
    5. A.equals(null) 要返回false.  

**重写equals方法的步骤，遵循以下三步：**  

1. 判断是否等于自身。

```Java
if (this == o) return true;
```

2. 判断是不是当前类型。

```Java
if (o == null || getClass() != o.getClass()) return false;
```

3. 比较当前对象的自定义数据，每一个类型都要比较，一个都不能少。

```Java
Person person = (Person) o;
return age == person.age && name.equals(person.name);
```

使用idea重写equals()方法的时候会提供一个jdk1.7或者1.8的模板，模板代码：

```Java
@Override
public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;
    Person person = (Person) o;
    return age != null && age == person.age &&
               name != null && name.equals(person.name);
}
```
(可以参考`Objects.equals(Object a, Object b))`方法：

```Java
public static boolean equals(Object a, Object b) {
    return (a == b) || (a != null && a.equals(b));
}
```

  - **如何重写hashCode()方法？**

　　上面在equals()方法的源码是上已经指出了重写equals()方法，通常都有必要重写hashCode()方法。    

　　如果你重写了equals()方法，那么一定要记得重写hashCode()方法．我们在大学计算机数据结构课程中都已经学过哈希表(hash table)了，hashCode()方法就是为哈希表服务的．
当我们在使用形如HashMap, HashSet这样前面以Hash开头的集合类时，hashCode()就会被隐式调用以来创建哈希映射关系．稍后我们再对此进行说明．这里我们先重点关注一下hashCode()方法的写法。   

　　＜Effective Java＞中给出了一个能最大程度上避免哈希冲突的写法，但我个人认为对于一般的应用来说没有必要搞的这么麻烦．如果你的应用中HashSet中需要存放上万上百万个对象时，那你应该严格遵循书中给定的方法．如果是写一个中小型的应用，那么下面的原则就已经足够使用了。  

**重写hashCode()方法的步骤**

首先参考下idea为我们提供的模板：  

```Java
@Override
public int hashCode() {
    return Objects.hash(name, age);
}
```

这里调用的是`Objects.hash(name, age)`的方法，源代码如下：  

```Java
public static int hash(Object... values) {
    return Arrays.hashCode(values);
}
public static int hashCode(Object a[]) {
        if (a == null)
            return 0;

        int result = 1;

        for (Object element : a)
            result = 31 * result + (element == null ? 0 : element.hashCode());

        return result;
}
```

从源代码中可以看到，最终调用的是**对应字段的hashCode()方法**（字段基本都有重写这个方法）。我们可以查看下String类型的hashCode()方法和int对应的hashCode()方法。  

```java
// int对应的hashCode()方法
@Override
public int hashCode() {
    return Integer.hashCode(value);
}
/**
 * The value of the {@code Integer}.
 *
 * @serial
 */
  private final int value;
```

```Java
//String 的hashCode()方法
/**
 * Returns a hash code for this string. The hash code for a
 * {@code String} object is computed as
 * <blockquote><pre>
 * s[0]*31^(n-1) + s[1]*31^(n-2) + ... + s[n-1]
 * </pre></blockquote>
 * using {@code int} arithmetic, where {@code s[i]} is the
 * <i>i</i>th character of the string, {@code n} is the length of
 * the string, and {@code ^} indicates exponentiation.
 * (The hash value of the empty string is zero.)
 *
 * @return  a hash code value for this object.
 */
public int hashCode() {
    int h = hash;
    if (h == 0 && value.length > 0) {
        char val[] = value;

        for (int i = 0; i < value.length; i++) {
            h = 31 * h + val[i];
        }
        hash = h;
    }
    return h;
}
```

对每个字符的ASCII码计算n - 1次方然后再进行加和，可见Sun对hashCode的实现是很严谨的. 这样能最大程度避免２个不同的String会出现相同的hashCode的情况。  

**重写equals()而没有重写hashCode()出现的问题**  

```Java
// 重写equals()而没有重写hashCode()出现的问题
Person2 a = new Person2("小明", 20);
Person2 b = new Person2("小明", 20);
testWithoutHashCode(a, b);

private static void testWithoutHashCode(Person2 person1, Person2 person2) {
        System.out.println(person1.equals(person2)); // 输出是为true
        Set<Person2> set = new HashSet<>();
        set.add(person1);

        System.out.println("重写了equals()而没有重写hashCode()方法：" + set.contains(person2));  // 输出是为false
    }

// 重写了equals()而没有重写hashCode()
class Person2 {
    private String name;
    private int age;

    public Person2(String name, int age) {
        this.name = name;
        this.age = age;
    }

    public Person2() {
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Person2 person = (Person2) o;
        return age != null && age == person.age &&
               name != null && name.equals(person.name);
        // 或者
        // return Objects.equals(name, person.name) && Objects.equals(age, person.age);
    }

}
```

**我们期望contains(c2)方法返回true, 但实际上它返回了false.**  
c1和c2的name和age都是相同的，为什么我把c1放到HashSet中后，再调用contains(c2)却返回false呢？这就是hashCode()在作怪了．因为你没有重写hashCode()方法，所以HashSet在查找c2时，会在不同的bucket中查找．比如c1放到05这个bucket中了，在查找c2时却在06这个bucket中找，这样当然找不到了．**因此，我们重写hashCode()的目的在于，在A.equals(B)返回true的情况下，A, B 的hashCode()要返回相同的值**．  

**两个重写之后则是另外的情况：**  

```Java
class Person {
    private String name;
    private int age;

    public Person(String name, int age) {
        this.name = name;
        this.age = age;
    }

    public Person() {
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Person person = (Person) o;
        return age != null && age == person.age &&
               name != null && name.equals(person.name);
        // 或者
        // return Objects.equals(name, person.name) && Objects.equals(age, person.age);
    }

    @Override
    public int hashCode() {
        return Objects.hash(name, age);
    }
}
public class TestEqualsAndHashCode {
    public static void main(String[] args) {
        Person person1 = new Person("小明", 20);
        Person person2 = new Person("小明", 20);
        System.out.println(person1 == person2); // false
        System.out.println(person1.equals(person2)); // false
        testWithBothMethod(person1, person2);
    }

    private static void testWithBothMethod(Person person1, Person person2) {
        System.out.println(person1.equals(person2)); // 输出是为true
        Set<Person> set = new HashSet<>();
        set.add(person1);

        System.out.println("重写了equals()和hashCode()方法："+ set.contains(person2)); // 输出是为true
    }
}
```

**每次调用hashCode()都返回一个常数这样就是去了hash的意义了，如果这样的话，HashMap, HashSet等集合类就失去了其 "哈希的意义"．用<Effective Java>中的话来说就是，哈希表退化成了链表．如果hashCode()每次都返回相同的数，那么所有的对象都会被放到同一个bucket中，每次执行查找操作都会遍历链表，这样就完全失去了哈希的作用．所以我们最好还是提供一个健壮的hashCode()为妙**。

最后面附上一个项目中完整的实例：

```Java
package com.ettrade.ngbss.jasperreport.data.datastruct.clientacreport;

import com.ettrade.ngbss.jasperreport.data.datastruct.common.BaseStruct;
import com.ettrade.ngbss.jasperreport.data.datastruct.common.Security;

public class ClientAccountProductPositionStruct extends Security implements BaseStruct {
    private String clientId;
    private String clientName;
    private String defaultAe;
    private String stockName;
    private double avgCost;
    private double nominal;
    private long quantity;

    // ... getter and setter method

    @Override
    public boolean equals(Object o) {
        if (this == o)
            return true;
        if (o == null || getClass() != o.getClass())
            return false;
        if (!super.equals(o)) // 这里是调用父类的equals()方法
            return false;

        ClientAccountProductPositionStruct struct = (ClientAccountProductPositionStruct) o;

        if (Double.compare(struct.avgCost, avgCost) != 0)
            return false;
        if (Double.compare(struct.nominal, nominal) != 0)
            return false;
        if (quantity != struct.quantity)
            return false;
        if (clientId != null ? !clientId.equals(struct.clientId) : struct.clientId != null)
            return false;
        if (clientName != null ? !clientName.equals(struct.clientName) : struct.clientName != null)
            return false;
        if (defaultAe != null ? !defaultAe.equals(struct.defaultAe) : struct.defaultAe != null)
            return false;
        return stockName != null ? stockName.equals(struct.stockName) : struct.stockName == null;
    }

    @Override
    public int hashCode() {
        int result = super.hashCode();
        long temp;
        result = 31 * result + (clientId != null ? clientId.hashCode() : 0);
        result = 31 * result + (clientName != null ? clientName.hashCode() : 0);
        result = 31 * result + (defaultAe != null ? defaultAe.hashCode() : 0);
        result = 31 * result + (stockName != null ? stockName.hashCode() : 0);
        temp = Double.doubleToLongBits(avgCost);
        result = 31 * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(nominal);
        result = 31 * result + (int) (temp ^ (temp >>> 32));
        result = 31 * result + (int) (quantity ^ (quantity >>> 32));
        return result;
    }
}
public class Security {
    protected String mkt;
    protected String stock;

    public Security() {

    }

    public Security(String market, String stockCode) {
        this.mkt = market;
        this.stock = stockCode;
    }

    // ... getter and setter method

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        Security security = (Security) o;

        if (mkt != null ? !mkt.equals(security.mkt) : security.mkt != null) return false;
        return stock != null ? stock.equals(security.stock) : security.stock == null;
    }

    @Override
    public int hashCode() {
        int result = mkt != null ? mkt.hashCode() : 0;
        result = 31 * result + (stock != null ? stock.hashCode() : 0);
        return result;
    }
}
```