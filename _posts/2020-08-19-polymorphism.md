---
layout: post
title: 다형성(Polymorphism)
date: 2020-08-19 14:32:23 +0900
category: java
---


# 다형성이란?
>같은 자료형에 여러 가지 객체를 대입하여 다양한 결과를 얻어내는 성질을 의미합니다.

    - 상속의 관계에서 사용
    - 최상위 클래스인 Object와도 사용가능
    - 오버로딩, 오버라이딩이 이에 속한다.

# 종류
- Upcasting (자동 형변환)
    > ```java
    > // 예제1)
    > Parent parent = new Child();
    >
    > // 예제2)
    > List<Integer> list = new ArrayList<Integer>();
    >
    > // 예제3)
    > List[] lists = {new ArrayList<Integer>(), new LinkedList<String>()};
    > lists[0].add(1);
    > lists[1].add("Hello");
    > ```
- Downcasting (명시적 형변환)
    > ```java
    > Child child = (Child)parent;
    > ```

## 퀴즈1. 출력결과는?
```java
class Fruit{ // 부모클래스
    public String name;
    public int price;
    
    public Fruit() {
    	name = "과일";
    	price = 100;
    	System.out.println("Fruit 인스턴스 생성!");
    }
    
    //info 메서드
    public void info(){
        System.out.println("과일이름 : "+name+", 가격 : "+price);
    }
    
}
 
class Apple extends Fruit{ // 자식클래스(부모클래스 상속) 
    public int size;
    public int count;
    
    public Apple() {
    	size = 5;
    	count = 10;
    	System.out.println("Apple 인스턴스 생성!");
    }
    
    @Override
    public void info() { // 메서드를 재정의 !!
        super.info();
        System.out.println("사과 크기 : "+size+", 갯수 : "+count);
    }
    
    
}
 
public class Main {
 
    public static void main(String[] args) {
    	
        // 1번
    	Fruit f = new Apple();
    	f.info();

        // 2번 (1번과 동일한 출력결과를 얻는다.)
        // Apple a = new Apple();
        // a.info();
    }
 
}
```
```java
Fruit 인스턴스 생성!
Apple 인스턴스 생성!
과일이름 : 과일, 가격 : 100
사과 크기 : 5, 갯수 : 10
```

## 퀴즈2. 출력결과는?
```java
class Parent {

    public String str = "Fruit";
    public String pa = "pa";

    public String getStr() {

        return str;
    }

    public static void hello() {

        System.out.println("헬로우");
    }
}

class Child extends Parent {

    public String str = "Apple";
    public String ch = "ch";

    public String getStr() {

        return str;
    }

    public static void hello() {

        System.out.println("안녕하세요");
    }
}

public class Main {

    public static void main(String[] args) {

        Child child = new Child();
        Parent parent = child;

        System.out.println(child.str);
        System.out.println(child.getStr());
        child.hello(); // static 이라 각 클래스의 이름을 가져오게된다.
        // 만약 Class의 static이 없다면 자식 클래스가 호출된다.

        System.out.println(parent.str);
        System.out.println(parent.getStr());
        parent.hello(); // static 이라 각 클래스의 이름을 가져오게된다.
        // 만약 Class의 static이 없다면 자식 클래스가 호출된다.

        System.out.println(parent.pa);
        System.out.println(child.pa); // 부모클래스의 변수도 사용할 수 있다.
        System.out.println(child.ch);

    }
}
```
```java
Apple
Apple
안녕하세요
Fruit
Apple
헬로우
pa
pa
ch
```