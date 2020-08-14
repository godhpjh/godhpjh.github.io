---
layout: post
title: StringBuilder vs StringBuffer
date: 2020-08-14 15:30:23 +0900
category: java
---

# 동기화여부에 대한 차이!
## StringBuilder
- 동기화 x
- 단일 쓰레드 환경에서 효율이 좋다
- 멀티 쓰레드 환경에서 다수의 쓰레드들이 StringBuilder 클래스에 접근이 가능 (= 취약함)

## StringBuffer
- Synchronized (동기화를 보장한다.)
- 멀티쓰레드 환경에서 동기화 지원
- 멀티 쓰레드 환경에서 다수의 쓰레드들이 StringBuffer 클래스에 접근이 불가능 (= 안정적)

```java
StringBuffer stringBuffer = new StringBuffer();
StringBuilder stringBuilder = new StringBuilder();

new Thread(() -> {
    for(int i=0; i<10000; i++) {
        stringBuffer.append(i);
        stringBuilder.append(i);
    }
}).start();

new Thread(() -> {
    for(int i=0; i<10000; i++) {
        stringBuffer.append(i);
        stringBuilder.append(i);
    }
}).start();

new Thread(() -> {
    try {
        Thread.sleep(5000);

        System.out.println("StringBuffer.length: "+ stringBuffer.length());
        System.out.println("StringBuilder.length: "+ stringBuilder.length());
    } catch (InterruptedException e) {
        e.printStackTrace();
    }
}).start();

결과: 
    StringBuffer.length: 77780
    StringBuilder.length: 76412
```

<br/>

### 쓰레드에 관련있는 경우 Buffer 권장
### 쓰레드에 관련없는 경우 Builder 권장

<br/>

## References
- https://novemberde.github.io/2017/04/15/String_0.html
- https://12bme.tistory.com/42