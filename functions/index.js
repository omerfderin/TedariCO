const functions = require('firebase-functions/v1');
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendNotification = functions.firestore
  .document("tedarikler/{tedarikId}")
  .onUpdate(async (change, context) => {
    const newData = change.after.data();
    const oldData = change.before.data();

    if (newData.basvuranlar.length !== oldData.basvuranlar.length) {
      const newApplicant = newData.basvuranlar.find(email => !oldData.basvuranlar.includes(email));
      const tedarikSahibiEmail = newData.kullanici;

      const userDoc = await admin.firestore().collection("users").doc(tedarikSahibiEmail).get();
      const token = userDoc.data()?.fcmToken;

      if (token) {
        const message = {
          notification: {
            title: "Yeni Başvuru!",
            body: `${newApplicant} adlı kullanıcı, "${tedarik.baslik}" tedarikinize başvurdu.`,
          },
          token: token,
        };

        try {
          await admin.messaging().send(message);
          console.log("Bildirim gönderildi.");
        } catch (error) {
          console.error("Bildirim hatası:", error);
        }
      } else {
        console.log("Kullanıcının FCM tokeni bulunamadı.");
      }
    }
  });

