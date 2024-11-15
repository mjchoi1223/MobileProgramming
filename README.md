# login_test

로그인 기능 테스트용 프로젝트입니다.

 https://www.postman.com/ 에 접속하여, post 요청으로 

https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=[firebase의webapikey값] 입력 후,

body 부분에

{ 

"email": "firebase에서 설정한 테스트 이메일 ex)[testing@gmail.com](mailto:testing@gmail.com)",

 "password": "firebase에서 설정한 테스트 이메일 비밀번호 ex)test123",

 "returnSecureToken": true

}

입력후 요청할 시, id 토큰을 얻어 로그인 합니다.

firebase의 web api와 android/app/src/google-services.json 파일 내용, lib/firebase_options.dart 파일 내용은 민감한 정보를 포함하니, 따로 올리겠습니다.
