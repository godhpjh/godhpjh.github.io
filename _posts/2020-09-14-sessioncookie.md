---
layout: post
title: Session vs Cookie
date: 2020-09-14 09:32:23 +0900
category: web
sitemap :
    changefreq : daily
    priority : 1.0
---

# Session
>브라우저가 종료되기 전까지 클라이언트의 요청을 유지하게 해주는 기술

![sesion](https://miro.medium.com/max/700/1*oiHghHg3sQW5ynmMCAtPAA.png)

- 로컬과 서버에 저장
- ID값만 가지고 있고 서버에도 저장이 되어있기 때문에 상대적으로 안전
- 브라우저를 종료하면 세션도 삭제된다.
- 요청마다 서버에서 처리를 해야하기 때문에 비교적 느리다.

<hr/>

# Cookie
> 클라이언트에 저장되는 Key-Value쌍의 작은 데이터 파일

![cookie](https://miro.medium.com/max/700/1*fWfKsO9P2rReNzJM2doBhQ.png)

- 로컬에 저장
- 탈취와 변조가 가능하므로 보안에 취약하다.
- 브라우저를 종료해도 파일로 남아있다.
- 파일에서 읽기 때문에 상대적으로 빠르다.

<hr/>

## References

https://medium.com/@chrisjune_13837/web-%EC%BF%A0%ED%82%A4-%EC%84%B8%EC%85%98%EC%9D%B4%EB%9E%80-aa6bcb327582
