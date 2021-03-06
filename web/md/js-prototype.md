JavaScript作为一个基于原型的OOP，和我们熟知的基于类的面向对象编程语言有很大的差异。如果不理解其中的本质含义，则无法深入理解JavaScript的诸多特性，以及由此产生的诸多“坑”。

# 原型
## 原型是什么

在讨论“原型”的概念之前，我们先来讨论一下“类”，也就是Java、C++等语言所使用的概念。

在基于类的编程语言中，都要先抽象出一个“类”，用来统一表示同一种对象。然后用这个抽象类创建出一个个实例（泛化），也就是对象object。最后，类和类之间通过组合、继承等特性共建出一个可以互动的系统，从而用这套人为创建的系统来模拟、操纵现实中的物理世界。它的三大特性为：
- 封装
- 继承
- 多态

然而，在原型概念中，有很多不同之处。

基于原型的编程范式提倡程序设计者关注实例对象的一系列行为，然后根据行为的不同划分出不同的原型，而不是事先抽象出一个类，再关注具体的对象。它最大的特点是可以动态修改对象的行为，具有高度灵活性。

**如果把基于类的对象称为“自上而下”式的顶层设计，那么基于原型的对象则可以被称为“自下而上”式的动态演化。**

> 这就像专业人士可能喜欢在看到老虎的时候，喜欢用猫科豹属豹亚种来描述它，但是对一些不那么正式的场合，“大猫”可能更为接近直观的感受一些（插播一个冷知识：比起老虎来，美洲狮在历史上相当长时间都被划分为猫科猫属，所以性格也跟猫更相似，比较亲人）。

基于原型的面向对象系统通过“复制”的方式来创建新对象，这实际上就是创建一个全新的对象。

原型系统的“复制”操作有两种实现思路：
- 并不是真正的复制一个对象，而是使新对象持有一个原型的引用；
- 切实的复制一个对象，复制对象和被复制对象再无任何关联。

JavaScript选择了前一种复制方式。

## JavaScript中的原型

抛开一切复杂的语法规则，JavaScript的原型系统的实质只有两条：
- 如果对象都有私有字段[[prototype]]，那它就是对象的原型；
- 读一个属性，如果对象自身没有，则继续访问对象的原型，直到找到或者原型为空为止。

从 ES6 以来，JavaScript提供了一系列内置函数，以便更直接地访问操纵原型，分别为：

- `Object.create` 根据指定的原型创建新对象，原型可以是`null`；
- `Object.getPrototypeOf` 获得一个对象的原型；
- `Object.setPrototypeOf` 设置一个对象的原型。

利用这三个方法，我们完全可以抛开基于类的面向对象思维，用原型的概念实现抽象和复用。

```js
// 作为“原型”的猫
var cat = {
    say(){
        console.log("meow~");
    },
    jump(){
        console.log("jump");
    }
}

// 作为“原型”的老虎
var tiger = Object.create(cat,  {
    say:{
        writable:true,
        configurable:true,
        enumerable:true,
        value:function(){
            console.log("roar!");
        }
    }
})


var anotherCat = Object.create(cat);

anotherCat.say();
// meow~

var anotherTiger = Object.create(tiger);

anotherTiger.say();
// roar!
```

## 早期版本中的原型

### ES3
在ES3之前的版本中，“类”的定义只是对象的一个私有属性 [[class]]，语言标准为内置类型Number、String、Date等指定了[[class]]属性，以表示它们的类。语言使用者唯一可以访问[[class]]属性的方式是` Object.prototype.toString` 。

```js
var o = new Object;
var n = new Number;
var s = new String;
var b = new Boolean;
var d = new Date;

console.log([o, n, s, b, d].map(v => Object.prototype.toString.call(v))); 
// 0: "[object Object]"
// 1: "[object Number]"
// 2: "[object String]"
// 3: "[object Boolean]"
// 4: "[object Date]"
```

### ES5
从ES5开始，[[class]] 私有属性被 `Symbol.toStringTag` 代替，`Object.prototype.toString` 的意义从命名上不再跟 `class` 相关。我们甚至可以自定义 `Object.prototype.toString` 的行为，以下代码展示了使用Symbol.`toStringTag`来自定义 `Object.prototype.toString` 的行为：
```js
var o = { [Symbol.toStringTag]: "MyObject" }
console.log(o + "");
// [object MyObject]
```

## `new`
`new` 运算符是JavaScript面向对象体系中非常重要的一员。在ES6之前，`new` 和函数基本上撑起了JavaScript的对象系统。`new` 运算接受一个构造器和一组参数，实际上做了这些事：

- 以构造器的 `prototype` 属性（注意与私有字段[[prototype]]的区分）为原型，创建新对象；
- 将 `this` 和调用参数传给构造器，执行；
- 如果构造器返回的是对象，则返回；否则返回第一步创建的对象。

实际上，它提供了两种方式用于操作对象的属性，其一是在构造器上添加属性；其二实在构造器的`prototype`上添加属性。

```js
function c1(){
    this.p1 = 1;
    this.p2 = function(){
        console.log(this.p1);
    }
} 
var o1 = new c1;
o1.p2();


function c2(){
}
c2.prototype.p1 = 1;
c2.prototype.p2 = function(){
    console.log(this.p1);
}

var o2 = new c2;
o2.p2();
```

在没有`Object.create`、 `Object.setPrototypeOf` 的早期版本中，`new` 运算是唯一一个可以指定[[prototype]]的方法（当时的mozilla提供了私有属性__proto__；但在目前，大多数浏览器已经支持这一私有属性__proto__）。所以，当时已经有人试图用它来代替后来的` Object.create`，我们甚至可以用它来实现一个 `Object.create` 的不完整的polyfill：
```js
Object.create = function(prototype) {
    var cls = function(){}
    cls.prototype = prototype;
    return new cls;
}
```
这段代码创建了一个空函数作为类，并把传入的原型挂在了它的 `prototype` 上，最后创建了一个它的实例，根据 `new` 的行为，这将产生一个以传入的第一个参数为原型的对象。这个函数无法做到与原生的 `Object.create` 一致，一个是不支持第二个参数，另一个是不支持 `null` 作为原型，所以放到今天意义已经不大了。

## ES6中的类`class`

ES6中， `class` 成为JavaScript官方支持的关键字，可以像其他语言一样定义类，并且还支持 `extends` 关键字来实现继承，`setter`、`getter` 也支持。至此，基于类的编程范式成为JavaScript官方支持的编程范式。如下所示：

```js
class Rectangle {
  constructor(height, width) {
    this.height = height;
    this.width = width;
  }
  // getter
  get area() {
    return this.calcArea();
  }
  // setter
  set area(area) {
      this.area = area;
  }
  // method
  calcArea() {
    return this.height * this.width;
  }
}
```
实现继承的用法：
```js
class Animal { 
  constructor(name) {
    this.name = name;
  }
  
  speak() {
    console.log(this.name + ' makes a noise.');
  }
}

class Dog extends Animal {
  constructor(name) {
    super(name); // call the super class constructor and pass in the name parameter
  }

  speak() {
    console.log(this.name + ' barks.');
  }
}

let d = new Dog('Mitzie');
d.speak(); // Mitzie barks.
```

所以从此以后，我们都应该使用 `class` 关键字正正经经地定义类，而不是用各种怪异的手法模拟对象。

# 原型链

JavaScript的每个对象都有一个指向其原型对象的关系链，当试图访问一个属性时，它不仅仅在对象上搜寻，而且还会在它的原型上搜寻，以及原型的原型上搜寻，直到找到属性或者达到此链条的顶端，这就是JavaScript的原型链，用来实现**继承**的核心逻辑。

## 函数对象和构造器对象

除过上面对于JavaScript对象的的一般分类方法，还有另一个角度，就是用对象来模拟函数和构造器。

JavaScript中函数对象的定义是：具有[[call]]私有字段的对象；构造器对象的定义是：具有私有字段[[construct]]的对象。

>JavaScript用对象模拟函数的设计代替了一般编程语言中的函数，它们可以像其它语言的函数一样被调用、传参。任何宿主只要提供了“具有[[call]]私有字段的对象”，就可以被 JavaScript 函数调用语法支持。

所以在JavaScript中，任何对象只要实现了[[call]]，它就是一个函数对象，可以去作为函数被调用。而如果它能实现[[construct]]，它就是一个构造器对象，可以作为构造器被调用。

另外，还有非常重要的一点：用`function`关键字创建的函数，既是函数（对象），又是构造器（对象）。

对于宿主和内置对象来说，[[call]]（作为函数被调用）的行为和[[construct]]（作为构造器被调用）的行为可能存在些许差异。而用户使用 `function` 语法或者`Function`构造器创建的对象来说，[[call]]和[[construct]]行为总是一致的。但是，在ES6之后用 `=>` 语法创建的函数仅仅是函数，它们无法被当作构造器使用。

```js
function f(){
    return 1;
}
var v = f(); //把f作为函数调用
var o = new f(); //把f作为构造器调用
```
上面这段代码的最后一行，它的执行过程如下：

1. 以 `f.prototype` 为原型创建一个新对象；
2. 以新对象`o`为 `this`，执行函数的[[call]]；
3. 如果[[call]]的返回值是对象，那么返回此对象；否则返回第一步创建的新对象。

## 显式原型`prototype` VS 隐式原型`__proto__`

### prototype

每一个函数在创建之后都会拥有一个名为`prototype`的属性，这个属性指向函数的原型对象。
Note：通过Function.prototype.bind方法构造出来的函数是个例外，它没有prototype属性。

那么，prototype的作用是什么呢？

>ECMAScript does not use classes such as those in C++, Smalltalk, or Java. Instead objects may be created in various ways including via a literal notation or via constructors which create objects and then execute code that initialises all or part of them by assigning initial values to their properties. Each constructor is a function that has a property named “prototype” that is used to implement prototype-based inheritance and shared properties.Objects are created by using constructors in new expressions; for example, new Date(2009,11) creates a new Date object. ----[ECMAScript Language Specification](https://link.zhihu.com/?target=http%3A//www.ecma-international.org/ecma-262/5.1/%23sec-4.2.1)

一句话，**`prototype`用来实现基于原型的继承与属性的共享**。`prototype`属性只有Function对象有。

### `__proto__`

> 遵循ECMAScript标准，someObject.[[Prototype]] 符号是用于指向 someObject 的原型。从 ECMAScript 6 开始，[[Prototype]] 可以通过 Object.getPrototypeOf() 和 Object.setPrototypeOf() 访问器来访问。这个等同于 JavaScript 的非标准但许多浏览器实现的属性 `__proto__`。

每个实例对象object都有一个私有属性[[Prototype]]（很多浏览器用 `__proto__`表示 ），指向它的构造函数的原型对象（ `prototype` ）。该原型对象也有一个自己的原型对象( `__proto__` ) ，层层向上直到一个对象的原型对象为 `null`。根据定义，`null` 没有原型，并作为这个原型链中的最后一个环节。

也就是说：**对每一个对象object，`__proto__`是构成JavaScript对象基于原型链的继承关系的具体实现细节。**

需要注意的是，**JavaScript的函数function也是对象（Function的实例，也就是函数对象）。所以，function也有了`__proto__`属性**，指向`Function.prototype`。

用下面两张图演直观感受一下原型链的真实样子：

![原型链1](../images/js-prototype-chain.jpg)

## 总结
- 牢记两点：
  - `__proto__`属性是对象所独有的；
  - `prototype`属性是函数所独有的；
  - 因为函数也是一种对象，所以同时拥有`__proto__`属性和`prototype`属性。
- `__proto__`：当访问对象属性时，如果该对象`obj`内部不存在这个属性，那么就会去它的原型对象`obj.__proto__`里找，顺着原型链一直向上找，直到`__proto__`为null。
- `prototype`：共享函数所实例化的对象的公有属性和方法。
