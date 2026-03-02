const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();

// ─── Scheduled Alert Check (runs every 1 hour) ───────────────────────────────
exports.checkAliveStatus = functions.pubsub
  .schedule("every 60 minutes")
  .onRun(async (context) => {
    console.log("Running 48-hour alive check...");

    const now = admin.firestore.Timestamp.now();
    const fortyEightHoursAgo = new Date(now.toDate().getTime() - 48 * 60 * 60 * 1000);

    // Query all ACTIVE connections where alertSent == false
    const snapshot = await db
      .collection("connections")
      .where("status", "==", "ACTIVE")
      .where("alertSent", "==", false)
      .get();

    const promises = [];

    for (const doc of snapshot.docs) {
      const data = doc.data();
      const lastAlive = data.lastAliveTimestamp;

      if (!lastAlive) continue;

      const lastAliveDate = lastAlive.toDate();
      if (lastAliveDate <= fortyEightHoursAgo) {
        console.log(`Sender ${data.senderId} has not pressed ALIVE in 48h. Alerting receiver ${data.receiverId}`);

        // Get receiver FCM token
        const receiverDoc = await db.collection("users").doc(data.receiverId).get();
        const receiverData = receiverDoc.data();
        const fcmToken = receiverData?.fcmToken;

        if (!fcmToken) {
          console.log(`Receiver ${data.receiverId} has no FCM token`);
          continue;
        }

        // Get sender name
        const senderDoc = await db.collection("users").doc(data.senderId).get();
        const senderName = senderDoc.data()?.name ?? "Your contact";

        // Send push notification to receiver
        const message = {
          token: fcmToken,
          notification: {
            title: "⚠️ Safety Alert",
            body: `${senderName} has not checked in for 48 hours!`,
          },
          data: {
            type: "alert_triggered",
            senderId: data.senderId,
          },
          android: {
            priority: "high",
            notification: {
              channelId: "alive_alerts",
              priority: "max",
              defaultSound: true,
            },
          },
          apns: {
            payload: {
              aps: {
                alert: {
                  title: "⚠️ Safety Alert",
                  body: `${senderName} has not checked in for 48 hours!`,
                },
                sound: "default",
                badge: 1,
              },
            },
          },
        };

        promises.push(
          admin.messaging().send(message).then(() => {
            // Mark alertSent = true
            return doc.ref.update({ alertSent: true });
          }).catch((err) => {
            console.error(`Failed to send alert for ${doc.id}:`, err);
          })
        );
      }
    }

    await Promise.all(promises);
    console.log(`Processed ${promises.length} alerts.`);
    return null;
  });

// ─── Send invite notification when connection is created ────────────────────
exports.onConnectionCreated = functions.firestore
  .document("connections/{senderId}")
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const senderId = context.params.senderId;

    if (!data.receiverId) return;

    // Get receiver FCM token
    const receiverDoc = await db.collection("users").doc(data.receiverId).get();
    const receiverData = receiverDoc.data();
    const fcmToken = receiverData?.fcmToken;
    if (!fcmToken) return;

    // Get sender name
    const senderDoc = await db.collection("users").doc(senderId).get();
    const senderName = senderDoc.data()?.name ?? "Someone";

    const message = {
      token: fcmToken,
      notification: {
        title: "Safety Monitoring Request",
        body: `${senderName} wants you to be their emergency contact`,
      },
      data: {
        type: "alive_request",
        senderId: senderId,
      },
      android: {
        priority: "high",
        notification: { channelId: "alive_requests" },
      },
    };

    try {
      await admin.messaging().send(message);
      console.log(`Invite sent to receiver ${data.receiverId}`);
    } catch (err) {
      console.error("Failed to send invite:", err);
    }
  });

// ─── Resend invite notification when connection is updated to PENDING ────────
exports.onConnectionUpdated = functions.firestore
  .document("connections/{senderId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const senderId = context.params.senderId;

    // Only trigger when status changes to PENDING (re-entry after rejection)
    if (before.status !== "PENDING" && after.status === "PENDING") {
      const receiverDoc = await db.collection("users").doc(after.receiverId).get();
      const fcmToken = receiverDoc.data()?.fcmToken;
      if (!fcmToken) return;

      const senderDoc = await db.collection("users").doc(senderId).get();
      const senderName = senderDoc.data()?.name ?? "Someone";

      const message = {
        token: fcmToken,
        notification: {
          title: "Safety Monitoring Request",
          body: `${senderName} wants you to be their emergency contact`,
        },
        data: {
          type: "alive_request",
          senderId: senderId,
        },
      };

      try {
        await admin.messaging().send(message);
      } catch (err) {
        console.error("Failed to resend invite:", err);
      }
    }
  });