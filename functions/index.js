// Firebase Admin ve Functions modüllerini içe aktarıyoruz
const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

// Firebase Admin SDK'sını başlatıyoruz
admin.initializeApp();

// Cloud Function: Tedarikler koleksiyonundaki değişiklikleri dinler
exports.sendApplicationNotification = onDocumentUpdated(
  "tedarikler/{tedarikId}",
  async (event) => {
    const beforeData = event.data.before.data();
    const afterData = event.data.after.data();

    // Eğer başvuranlar listesi güncellenmişse:
    if (afterData.basvuranlar.length > beforeData.basvuranlar.length) {
      const yeniBasvuran = afterData.basvuranlar[afterData.basvuranlar.length - 1];
      const kartSahibiEmail = afterData.kullanici;

      try {
        // Kart sahibinin FCM token'ını almak için users koleksiyonunu sorgula
        const userDoc = await admin
          .firestore()
          .collection("users")
          .doc(kartSahibiEmail)
          .get();

        if (userDoc.exists && userDoc.data().fcmToken) {
          const token = userDoc.data().fcmToken;

          // Bildirim içeriği
          const payload = {
            notification: {
              title: "Yeni Başvuru!",
              body: `${yeniBasvuran} isimli kullanıcı kartınıza başvurdu.`,
              clickAction: "FLUTTER_NOTIFICATION_CLICK",
            },
          };

          // Bildirimi gönder
          await admin.messaging().sendToDevice(token, payload);
          console.log("Bildirim başarıyla gönderildi!");
        } else {
          console.log("Kart sahibi için FCM Token bulunamadı.");
        }
      } catch (error) {
        console.error("Bildirim gönderimi sırasında hata oluştu:", error);
      }
    }
  }
);
