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

- ID값만 가지고 있고 서버에도 저장이 되어있기 때문에 상대적으로 안전
- 브라우저를 종료하면 세션도 삭제된다.
- 요청마다 서버에서 처리를 해야하기 때문에 비교적 느리다.

<hr/>

# Cookie
>dd

![cookie](https://miro.medium.com/max/700/1*fWfKsO9P2rReNzJM2doBhQ.png)

- 탈취와 변조가 가능하므로 보안에 취약하다.
- 브라우저를 종료해도 파일로 남아있다.
- 파일에서 읽기 때문에 상대적으로 빠르다.

<hr/>

## References

https://asfirstalways.tistory.com/335

https://gem1n1.tistory.com/96
