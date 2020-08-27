---
layout: post
title: singleton
date: 2020-08-27 09:32:23 +0900
category: java
---

# 싱글톤 패턴(Singleton Pattern)

    애플리케이션에서 하나의 인스턴스를 만들어 사용하기 위한 패턴입니다.


## 목적
> 커넥션 풀, 스레드 풀, 디바이스 설정 객체 등의 경우, 인스턴스를 여러 개 만들게 되면 자원을 낭비하게 되거나 버그를 발생시킬 수 있으므로 오직 하나만 생성하고 그 인스턴스를 사용하도록 하는 것


## 구현

- new 를 실행할 수 없도록 생성자에 private 접근 제어자를 지정
- 유일한 단일 객체를 반환할 수 있도록 정적 메소드를 지원
- 유일한 단일 객체를 참조할 정적 참조변수가 필요


### 구현1) 일반 싱글톤 구조

```java
public class Singleton {
    private static Singleton singletonObject;

    private Singleton() {}

    public static Singleton getInstance() {
        if (singletonObject == null) {
            singletonObject = new Singleton();
        }
        return singletonObject;
    }
}
```
- 멀티스레딩 환경에서 싱글턴 패턴을 적용하다보면 문제가 발생할 수 있다.
- 동시에 접근하다가 하나만 생성되어야 하는 인스턴스가 두 개 생성될 수 있는 것

<hr/>

### 구현2) synchronized 키워드 사용

```java
public class Singleton {
    private static Singleton singletonObject;

    private Singleton() {}

    public static synchronized Singleton getInstance() {
        if (singletonObject == null) {
            singletonObject = new Singleton();
        }
        return singletonObject;
    }
}
```
- 성능상에 문제점이 존재한다.

<hr/>

### 구현3) 동기화 영역 지정

```java
public class Singleton {
    private static volatile Singleton singletonObject;

    private Singleton() {}

    public static Singleton getInstance() {
        if (singletonObject == null) {
            synchronized (Singleton.class) {
                if(singletonObject == null) {
                    singletonObject = new Singleton();
                }
            }
        }
        return singletonObject;
    }
}
```
- DCL(Double Checking Locking)을 써서 getInstance()에서 동기화 되는 영역을 줄일 수 있다.
- 초기에 객체를 생성하지 않으면서도 동기화하는 부분을 작게 만들었다
- 그러나, 멀티코어 환경에서 동작할 때, 하나의 CPU 를 제외하고는 다른 CPU 가 lock 이 걸리게 된다


<hr/>

### 구현4) volatile를 이용

```java
public class Singleton {
    private static volatile Singleton singletonObject = new Singleton();

    private Singleton() {}

    public static Singleton getSingletonObject() {
        return singletonObject;
    }
}
```
- volatile : 컴파일러가 특정 변수에 대해 옵티마이져가 캐싱을 적용하지 못하도록 하는 키워드이다.
- 클래스가 로딩되는 시점에 미리 객체를 생성해두고 그 객체를 반환한다.


## References

https://asfirstalways.tistory.com/335