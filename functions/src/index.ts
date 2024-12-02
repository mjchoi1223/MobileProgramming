import {onDocumentCreated} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";

admin.initializeApp();

export const sendFriendRequestNotification = onDocumentCreated(
  "friendships/{friendshipId}",
  async (event) => {
    const data = event.data?.data(); // 문서 데이터 가져오기
    const targetId = data?.targetId; // 친구 요청 대상자 ID

    if (!targetId) {
      console.error("Error: No targetId found in the document.");
      return;
    }

    try {
      // Firestore에서 targetId 사용자 정보 가져오기
      const userDoc = await admin
        .firestore()
        .collection("users")
        .doc(targetId)
        .get();

      if (!userDoc.exists) {
        console.error(`Error: User document with ID ${targetId} not found.`);
        return;
      }

      const fcmToken = userDoc.data()?.fcmToken;
      if (!fcmToken) {
        console.log(
          `Warning: User with ID ${targetId} does not have an FCM token.`
        );
        return;
      }

      // FCM 알림 데이터 생성
      const payload = {
        notification: {
          title: "새 친구 요청",
          body: "친구 요청을 확인하세요!",
        },
        token: fcmToken,
      };

      // FCM 알림 전송
      await admin.messaging().send(payload);
      console.log(`Success: Notification sent to user with ID ${targetId}.`);
    } catch (error) {
      console.error(
        `Error while sending notification to user with ID ${targetId}:`,
        error
      );
    }
  }
);
