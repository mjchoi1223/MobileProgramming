로그인 기능 테스트용 프로젝트입니다.
https://www.postman.com/ 에 접속하여, 
post 요청으로 https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=[firebase의webapikey값]  입력 후,
body 부분에 
{
"email": "firebase에서 설정한 테스트 이메일",
"password": "firebase에서 설정한 테스트 이메일 비밀번호",
"returnSecureToken": true
}
입력후 요청할 시, id 토큰을 얻어 로그인 합니다.
