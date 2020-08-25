---
layout: post
title: var, let, const
date: 2020-08-22 13:32:23 +0900
category: javascript
---

먼저 가장 큰 차이점은 변수 선언 방식에 따라 다릅니다.

# var 
- 변수를 선언 이후에도 에러를 발생하지 않고 각기 다른 값을 가진다.
- 유연한 변수를 가질 수 있는 간단한 테스트용도
- 복잡한 코드일 경우 값이 바뀔 우려가 있다. (위험함)
- ES6 이후 이를 보완하기 위해 let, const 변수가 추가되었다.
```javascript
var name = "psh"
console.log(name)

var name = "debugger" // 같은 변수 이름 반복사용 가능, but 위험한 코딩
console.log(name)

name = "bye"
```

# let
- 변수 재선언 불가
- 변수 재할당 가능
```javascript
var name = "psh"
console.log(name)

var name = "debugger" // Error
console.log(name)
// Uncaught SyntaxError: Identifier 'name' has already been declared

name = "bye" // 재할당 가능
```

# const
- 변수 재선언 불가
- 변수 재할당 불가
```javascript
var name = "psh"
console.log(name)

var name = "debugger" // Error
console.log(name)
// Uncaught SyntaxError: Identifier 'name' has already been declared

name = "bye" // 재할당 불가능  (Error)
//Uncaught TypeError: Assignment to constant variable.
```


## let과 const의 가장 큰 차이점은 immutable 여부!


## References
https://velog.io/@bathingape/JavaScript-var-let-const-%EC%B0%A8%EC%9D%B4%EC%A0%90