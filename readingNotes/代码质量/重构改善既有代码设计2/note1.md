#### 代码坏味道

##### 神秘命名

整洁代码最重要的一环就是好的名字，所以我们会深思熟虑如何给函数、模块、变量和类命名，使它们能清晰地表明自己的功能和用法。

**函数命名、字段命名、变量命名**等等。

##### 重复代码

如果你在一个以上的地点看到相同的代码结构，那么可以肯定：设法将它们合而为一，程序会变得更好。一旦有重复代码存在，阅读这些重复的代码时你就必须加倍仔细，留意其间细微的差异。**如果要修改重复代码，你必须找出所有的副本来修改**。

最单纯的重复代码就是“同一个类的两个函数含有相同的表达式”。如果重复代码只是相似而不是完全相同，请首先尝试用**移动语句（223）重组代码顺序**，把相似的部分放在一起以便提炼。**如果重复的代码段位于同一个超类的不同子类中，可以使用函数上移（350）来避免在两个子类之间互相调用**。

##### 过长函数

更好的阐释力、更易于分享、更多的选择—都是由小函数来支持的。

函数越长，就越难理解。小函数也会给代码的阅读者带来一些负担，因为你必须经常切换上下文，才能看明白函数在做什么。不过说到底，**让小函数易于理解的关键还是在于良好的命名**。**如果你能给函数起个好名字，阅读代码的人就可以通过名字了解函数的作用，根本不必去看其中写了些什么**。

最终的效果是：**你应该更积极地分解函数**。我们遵循这样一条原则：**每当感觉需要以注释来说明点什么的时候，我们就把需要说明的东西写进一个独立函数中，并以其用途（而非实现手法）命名**。我们可以对一组甚至短短一行代码做这件事。哪怕替换后的函数调用动作比函数自身还长，只要函数名称能够解释其用途，我们也该毫不犹豫地那么做。关键不在于函数的长度，而在于函数“做什么”和“如何做”之间的语义距离。

引入参数对象（140）和保持对象完整（319）则可以将过长的参数列表变得更简洁一些。如果你已经这么做了，仍然有太多临时变量和参数，那就应该使出我们的杀手锏——以命令取代函数（337）。

条件表达式：你可以使用分解条件表达式（260）处理条件表达式。如果有多个switch语句基于同一个条件进行
分支选择，就应该使用以多态取代条件表达式（272）。

循环：你应该将循环和循环内的代码提炼到一个独立的函数中。如果你发现提炼出的循环很难命名，可能是因为其中做了几件不同的事。拆分循环（227）将其拆分成各自独立的任务

##### 过长参数列表

如果可以向某个参数发起查询而获得另一个参数的值，那么就可以使用以查询取代参数（324）去掉这第二个参数。

如果你发现自己正在从现有的数据结构中抽出很多数据项，就可以考虑使用保持对象完整（319）手法，直接传入原来的数据结构。

如果有几项参数总是同时出现，可以用引入参数对象（140）将其合并成一个对象。如果某个参数被用作区分函数行为的标记（flag），可以使用移除标记参数（314）。

你可以使用函数组合成类（144），将这些共同的参数变成这个类的字段。如果戴上函数式编程的帽子，我们会说，这个重构过程创造了一组部分应用函数（partially applied function）。

##### 全局数据

全局数据的问题在于，从代码库的任何一个角落都可以修改它，而且没有任何机制可以探测出到底哪段代码做出了修改。首要的防御手段是**封装变量**（132），每当我们看到可能被各处的代码污染的数据，这总是我们应对的第一招。你把全局数据用一个函数包装起来，至少你就能看见修改它的地方，并开始控制对它的访问。随后，最好将这个函数（及其封装的数据）搬移到一个类或模块中，只允许模块内的代码使用它，从而尽量控制其作用域。

##### 可变数据

可以用封装变量（132）来确保所有数据更新操作都通过很少几个函数来进行，使其更容易监控和演进。

如果一个变量在不同时候被用于存储不同的东西，可以使用拆分变量（240）将其拆分为各自不同用途的变量，从而避免危险的更新操作。

##### 发散式变化

也就是类的单一职责。



### 重构案例

#### 提炼函数

```javascript
function printOwing(invoice) {
　printBanner();
　let outstanding = calculateOutstanding();

　//print details
　console.log(`name: ${invoice.customer}`);
　console.log(`amount: ${outstanding}`);
}
```

之后

```javascript
function printOwing(invoice) {
　printBanner();
　let outstanding = calculateOutstanding();
　printDetails(outstanding);

　function printDetails(outstanding) {
　　console.log(`name: ${invoice.customer}`);
　　console.log(`amount: ${outstanding}`);
　}
}
```

##### 动机

**如果你需要花时间浏览一段代码才能弄清它到底在干什么，那么就应该将其提炼到一个函数中，并根据它所做的事为其命名**。以后再读到这段代码时，你一眼就能看到函数的用途，大多数时候根本不需要关心函数如何达成其用途。

小函数得有个好名字才行，所以你必须在命名上花心思。

##### 做法

- 创造一个新函数，根据这个函数的意图来对它命名（以它“做什么”来命名，而不是以它“怎样做”命名）。
- 仔细检查提炼出的代码，看看其中是否引用了作用域限于源函数、在提炼出的新函数中访问不到的变量。若是，以参数的形式将它们传递给新函数。
- 查看其他代码是否有与被提炼的代码段相同或相似之处。如果有，考虑使用以函数调用取代内联代码（222）令其调用提炼出的新函数。

#### 内联函数

```javascript
function getRating(driver) {
　return moreThanFiveLateDeliveries(driver) ? 2 : 1;
}

function moreThanFiveLateDeliveries(driver) {
　return driver.numberOfLateDeliveries > 5;
}
```

after

```javascript
function getRating(driver) {
　return (driver.numberOfLateDeliveries > 5) ? 2 : 1;
}
```

##### 动机

- 但有时候你会遇到某些函数，**其内部代码和函数名称同样清晰易读**。也可能你重构了该函数的内部实现，使其内容和其名称变得同样清晰。若果真如此，你就应该去掉这个函数，直接使用其中的代码。

- 我手上有一群组织不甚合理的函数

##### 做法

- 检查函数，确定它不具多态性。如果该函数属于一个类，并且有子类继承了这个函数，那么就无法内联。

#### 提炼变量

```javascript
return order.quantity * order.itemPrice -
　Math.max(0, order.quantity - 500) * order.itemPrice * 0.05 +
　Math.min(order.quantity * order.itemPrice * 0.1, 100);
```

after

```javascript
const basePrice = order.quantity * order.itemPrice;
const quantityDiscount = Math.max(0, order.quantity - 500) * order.itemPrice * 0.0
5;
const shipping = Math.min(basePrice * 0.1, 100);
return basePrice - quantityDiscount + shipping;
```

##### 动机

- 表达式有可能非常复杂而难以阅读。这种情况下，局部变量可以帮助我们将表达式分解为比较容易管理的形式。

##### 范例

```javascript
class Order {
　constructor(aRecord) {
　　this._data = aRecord;
　}

　get quantity() {return this._data.quantity;}
　get itemPrice() {return this._data.itemPrice;}
  get price() {
　　return this.quantity * this.itemPrice -
　　　Math.max(0, this.quantity - 500) * this.itemPrice * 0.05 +
　　　Math.min(this.quantity * this.itemPrice * 0.1, 100);
　}
}
```

这些变量名所代表的概念，适用于整个Order类，而不仅仅是“计算价格”的上下文。既然如此，我更愿意将它们提炼成方法，而不是变量。

```javascript
class Order {
　constructor(aRecord) {
　　this._data = aRecord;
　}
　get quantity() {return this._data.quantity;}
　get itemPrice() {return this._data.itemPrice;}

　get price() {
　　return this.basePrice - this.quantityDiscount + this.shipping;
　}
　get basePrice()        {return this.quantity * this.itemPrice;}
　get quantityDiscount() {return Math.max(0, this.quantity - 500) * this.itemPrice
 * 0.05;}
　get shipping()         {return Math.min(this.basePrice * 0.1, 100);}
}
```

#### 内联变量

```javascript
let basePrice = anOrder.basePrice;
return (basePrice > 1000);
// after
return anOrder.basePrice > 1000;
```

##### 动机

这个名字并不比表达式本身更具表现力。还有些时候，变量可能会妨碍重构附近的代码。若果真如此，就应该通过内联的手法消除变量。

#### 改变函数声明

```javascript
// 计算周长
function circum(radius) {
  return 2 * Math.PI * radius;
}
// after
function circumference(radius) {
  return 2 * Math.PI * radius;
}
```

##### 动机

函数是我们将程序拆分成小块的主要方式。函数声明则展现了如何将这些小块组合在一起工作。一**个好名字能让我一眼看出函数的用途，而不必查看其实现代码**。

有一个改进函数名字的好办法：先写一句注释描述这个函数的用途，再把这句注释变成函数的名字。

##### 范例

1 如上面代码那样

但如果调用者很多，事情就会变得很棘手。另外，如果函数的名字并不唯一，也可能造成问题。例如，我想给代表“人”的Person类的changeAddress函数改名，但同时在代表“保险合同”的InsuranceAgreement类中也有一个同名的函数，而我并不想修改后者的名字。这个要注意！

2 添加参数

想象一个管理图书馆的软件，其中有代表“图书”的Book类，它可以接受顾客（customer）的预订（reservation）：

```javascript
addReservation(customer) {
  this._reservations.push(customer);
}
// after
addReservation(customer, isPriority) {
  this._reservations.push(customer);
}
```

#### 封装变量

```javascript
let defaultOwner = {firstName: "Martin", lastName: "Fowler"};
// after
let defaultOwnerData = {firstName: "Martin", lastName: "Fowler"};
export function defaultOwner()       {return defaultOwnerData;}
export function setDefaultOwner(arg) {defaultOwnerData = arg;}
// 使用的地方
spaceship.owner = getDefaultOwner();
setDefaultOwner({firstName: "Rebecca", lastName: "Parsons"});
```

##### 动机

**如果想要搬移一处被广泛使用的数据，最好的办法往往是先以函数形式封装所有对该数据的访问**。这样，我就能把“重新组织数据”的困难任务转化为“重新组织函数”这个相对简单的任务。

- 对于所有可变的数据，只要它的作用域超出单个函数，我就会将其封装起来，只允许通过函数访问。数据的作用域越大，封装就越重要。

##### 做法

- 创建封装函数，在其中访问和更新变量值。

- 执行静态检查。
- 限制变量的可见性。

前面介绍的基本重构手法对数据结构的引用做了封装，使我能控制对该数据结构的访问和重新赋值，但并不能控制对结构内部数据项的修改：

```javascript
const owner1 = defaultOwner(); 
assert.equal("Fowler", owner1.lastName, "when set"); 
const owner2 = defaultOwner();
owner2.lastName = "Parsons";
assert.equal("Parsons", owner1.lastName, "after change owner2"); // is this ok?
```

前面的基本重构手法只封装了对最外层数据的引用。很多时候这已经足够了。但也有很多时候，我需要把封装做得更深入，**不仅控制对变量引用的修改，还要控制对变量内容的修改**。

最简单的办法是禁止对数据结构内部的数值做任何修改。我最喜欢的一种做法是修改取值函数，使其返回该数据的一份副本。

```javascript
let defaultOwnerData = {firstName: "Martin", lastName: "Fowler"};
export function defaultOwner()       {return Object.assign({}, defaultOwnerData);}
export function setDefaultOwner(arg) {defaultOwnerData = arg;}
```



#### 变量改名

#### 引入参数对象

```javascript
function amountInvoiced(startDate, endDate) {...} 
function amountReceived(startDate, endDate) {...} 
function amountOverdue(startDate, endDate) {...}
// after
function amountInvoiced(aDateRange) {...} 
function amountReceived(aDateRange) {...} 
function amountOverdue(aDateRange) {...}
```

**一组数据项总是结伴同行，出没于一个又一个函数**。这样一组数据就是所谓的数据泥团，我喜欢代之以一个数据结构。

#### 函数组合成类

主要是类似于Java中的组合类的使用。

```javascript
function base(aReading) {...}
function taxableCharge(aReading) {...} 
function calculateBaseCharge(aReading) {...}
```

重构后

```javascript
class Reading { 
  base() {...}
  taxableCharge() {...} 
  calculateBaseCharge() {...}
}
```

**如果发现一组函数形影不离地操作同一块数据**（通常是将这块数据作为参数传递给函数），我就认为，是时候组建一个类了。

##### 做法

- 运用封装记录（162）对多个函数共用的数据记录加以封装。
- 对于使用该记录结构的每个函数，运用搬移函数（198）将其移入新类。

- 用以处理该数据记录的逻辑可以用提炼函数（106）提炼出来，并移入新类。

##### 范例

每个月会有软件读取茶水计量器的数据，得到类似这样的读数（reading）：

reading = {customer: "ivan", quantity: 10, month: 5, year: 2017};

###### 客户端1

```javascript
const aReading = acquireReading();
const baseCharge = baseRate(aReading.month, aReading.year) * aReading.quantity;
```

###### 客户端2

```javascript
const aReading = acquireReading();
const base = (baseRate(aReading.month, aReading.year) * aReading.quantity); 
const taxableCharge = Math.max(0, base - taxThreshold(aReading.year));
```

计算基础费用的公式被重复了两遍。

###### 客户端3

```javascript
const aReading = acquireReading();
const basicChargeAmount = calculateBaseCharge(aReading);

function calculateBaseCharge(aReading) {
  return baseRate(aReading.month, aReading.year) * aReading.quantity;
}
```

看到这里，我有一种自然的冲动，想把前面两处客户端代码都改为使用这个函数。但这样一个顶层函数的问题在于，它通常位于一个文件中，读者不一定能想到来这里寻找它。我更愿意对代码多做些修改，让该函数与其处理的数据在空间上有更紧密的联系。为此目的，不妨把数据本身变成一个类。

```javascript
class Reading {
　constructor(data) {
　　this._customer = data.customer;
　　this._quantity = data.quantity;
   this._month = data.month;
　　this._year = data.year;
　}
　get customer() {return this._customer;}
　get quantity() {return this._quantity;}
　get month()    {return this._month;}
　get year()     {return this._year;}
}
```

首先，我想把手上已有的函数calculateBaseCharge搬到新建的Reading类中。一得到原始的读数数据，我就用Reading类将它包装起来，然后就可以在函数中使用Reading类了。

客户端3

```javascript
const rawReading = acquireReading(); 
const aReading = new Reading(rawReading);
const basicChargeAmount = calculateBaseCharge(aReading);
```

然后我用搬移函数（198）把calculateBaseCharge搬到新类中。

class Reading

```javascript
get calculateBaseCharge() {
  return baseRate(this.month, this.year) * this.quantity;
}
```

客户端3

```javascript
const rawReading = acquireReading(); 
const aReading = new Reading(rawReading);
const basicChargeAmount = aReading.calculateBaseCharge;
```

然后改名

```javascript
get baseCharge() {
  return baseRate(this.month, this.year) * this.quantity;
}
// 调用
const rawReading = acquireReading(); 
const aReading = new Reading(rawReading);
const basicChargeAmount = aReading.baseCharge;
```

客户端1

```javascript
const rawReading = acquireReading(); 
const aReading = new Reading(rawReading);
const baseCharge = aReading.baseCharge;
```

客户端2的计算提炼成函数移到Reading中

```javascript
function taxableChargeFn(aReading) {
  return Math.max(0, aReading.baseCharge - taxThreshold(aReading.year));
}
```

客户端2

```javascript
const rawReading = acquireReading(); 
const aReading = new Reading(rawReading);
const taxableCharge = aReading.taxableCharge;
```

#### 函数组合变换

```javascript
function base(aReading) {...}
function taxableCharge(aReading) {...}
// after

function enrichReading(argReading) {
  const aReading = _.cloneDeep(argReading);
  aReading.baseCharge = base(aReading);
  aReading.taxableCharge = taxableCharge(aReading);
  return aReading;
}
```

在软件中，经常需要把数据“喂”给一个程序，让它再计算出各种派生信息。这些派生数值可能会在几个不同地方用到，因此这些计算逻辑也常会在用到派生数据的地方重复。我更愿意把所有计算派生数据的逻辑收拢到一处，这样始终可以在固定的地方找到和更新这些逻辑，避免到处重复。

也就是构造数据最好是放一块构造，有一个具体的builder方法。

一个方式是采用数据变换（transform）函数：这种函数接受源数据作为输入，计算出所有的派生数据，将派生数据以字段形式填入输出数据。有了变换函数，我就始终只需要到变换函数中去检查计算派生数据的逻辑。

#### 拆分函数内部代码为多个函数

```javascript
const orderData = orderString.split(/\s+/);
const productPrice = priceList[orderData[0].split("-")[1]]; 
const orderPrice = parseInt(orderData[1]) * productPrice;

// after
const orderRecord = parseOrder(order);
const orderPrice = price(orderRecord, priceList);

function parseOrder(aString) {
　const values = aString.split(/\s+/); 
　return ({
　　productID: values[0].split("-")[1], 
　　quantity: parseInt(values[1]),
　});
}
function price(order, priceList) {
　return order.quantity * priceList[order.productID];
}
```

**每当看见一段代码在同时处理两件不同的事，我就想把它拆分成各自独立的模块**，因为这样到了需要修改的时候，我就可以单独处理每个主题，而不必同时在脑子里考虑两个不同的主题。

编译器的任务很直观：接受文本（用某种编程语言编写的代码）作为输入，将其转换成某种可执行的格式（例如针对某种特定硬件的目标码）。随着经验加深，我们发现把这项大任务拆分成一系列阶段会很有帮助：首先对文本做词法分析，然后把token解析成语法树，然后再对语法树做几步转换（如优化），最后生成目标码。每一步都有边界明确的范围，我可以聚焦思考其中一步，而不用理解其他步骤的细节。
