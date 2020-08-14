---
layout: post
title: 오버로딩 vs 오버라이딩
date: 2020-08-14 15:30:23 +0900
category: java
---


# 오버로딩 (Overloading)
> 같은 메서드 이름을 사용하면서 파라미터의 수나 자료형을 달리하여 다양한 유형의 방식으로 사용할 수 있도록 하는 것

사용예시)
```java
    // 기본 메서드
    void print(){
        System.out.println("매개변수 없음");
    }
    
    // 매개변수 int형이 2개인 메서드
    void print(int a, int b){
        System.out.println("매개변수 :"+a+", "+b);
    }
    
    // 매개변수 String형이 1개인 메서드
    void print(String s){
        System.out.println("매개변수 : "+ s);
    }
```

혼동주의)
```java
    void print() {} // o
    void print(int a, int b) {} // o
    void print(double a, double b) // o
    void print(String s) {} // o

    // 리턴타입이 다른 경우
    int print(int a, int b) // x (오버로딩이 아니다) 컴파일 에러
    boolean print(String s) // x (오버로딩이 아니다) 컴파일 에러
```

<br/><br/><br/>

# 오버라이딩 (Overriding))
> 부모 클래스로부터 전달받은 메서드를 자식 클래스에서 내용을 재정의하여 사용 할 수 있도록 하는 것
- 메서드의 이름과 리턴타입, 파라미터를 동일하게 가져가고 구현부를 재정의하여 사용해야한다.

사용예시)
```java
class Fruit{ // 부모클래스
    public String name;
    public int price;
    
    //info 메서드
    public void info(){
        System.out.println("과일이름 : "+name+", 가격 : "+price);
    }
    
}
 
class Apple extends Fruit{ // 자식클래스(부모클래스 상속) 
    public int size;
    public int count;
    
    public void info() {// 메서드를 재정의 !!
        super.info();
        System.out.println("사과 크기 : "+size+", 갯수 : "+count);
    }
}
 
public class Test {
 
    public static void main(String[] args) {
        
        // 인스턴스 생성
        Apple apple = new Apple();
        
        // 객체의 변수 설정
        apple.name = "사과";
        apple.price = 30;
        apple.size = 20;
        apple.count = 5;

        //호출
        apple.info();        
        
    }
 
}

```
```java
/**  console
    과일이름 : 사과, 가격 : 30
    사과 크기 : 20, 갯수 : 5 
**/
```