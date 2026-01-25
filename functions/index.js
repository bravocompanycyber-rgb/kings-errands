const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// Generic function to send notifications
const sendNotification = async (userId, payload) => {
  const userDoc = await admin.firestore().collection('users').doc(userId).get();
  const fcmToken = userDoc.data()?.fcmToken;

  if (fcmToken) {
    try {
      await admin.messaging().sendToDevice(fcmToken, payload);
      console.log('Notification sent successfully');
    } catch (error) {
      console.error('Error sending notification:', error);
    }
  }
};

// Errand accepted
exports.errandAccepted = functions.firestore
  .document('errands/{errandId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    if (before.status === 'posted' && after.status === 'accepted') {
      const customerId = after.customerId;
      const payload = {
        notification: {
          title: 'Errand Accepted!',
          body: `Your errand "${after.title}" has been accepted.`,
        },
      };
      await sendNotification(customerId, payload);
    }
  });

// Errand completed
exports.errandCompleted = functions.firestore
  .document('errands/{errandId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    if (before.status === 'accepted' && after.status === 'completed') {
      const customerId = after.customerId;
      const payload = {
        notification: {
          title: 'Errand Completed!',
          body: `Your errand "${after.title}" has been completed.`,
        },
      };
      await sendNotification(customerId, payload);
    }
  });

// New errand posted
exports.newErrandPosted = functions.firestore
  .document('errands/{errandId}')
  .onCreate(async (snap, context) => {
    const usersSnapshot = await admin.firestore().collection('users').where('role', '==', 'runner').get();
    const payload = {
        notification: {
          title: 'New Errand Available!',
          body: `A new errand has been posted near you.`,
        },
      };

    const promises = usersSnapshot.docs.map(doc => sendNotification(doc.id, payload));
    await Promise.all(promises);
  });

// Payment approved
exports.paymentApproved = functions.firestore
    .document('payments/{paymentId}')
    .onUpdate(async (change, context) => {
        const before = change.before.data();
        const after = change.after.data();

        if (before.status !== 'approved' && after.status === 'approved') {
            const runnerId = after.runnerId;
            const payload = {
                notification: {
                    title: 'Payment Approved!',
                    body: `Your payment for the errand "${after.errandTitle}" has been approved.`,
                },
            };
            await sendNotification(runnerId, payload);
        }
    });

// Broadcasts
exports.newBroadcast = functions.firestore
  .document('broadcasts/{broadcastId}')
  .onCreate(async (snap, context) => {
    const broadcast = snap.data();
    const usersSnapshot = await admin.firestore().collection('users').get();
    const payload = {
        notification: {
          title: 'New Broadcast from Admin',
          body: broadcast.message,
        },
      };

    const promises = usersSnapshot.docs.map(doc => sendNotification(doc.id, payload));
    await Promise.all(promises);
  });

// Chat messages
exports.newChatMessage = functions.firestore
  .document('chats/{chatId}/messages/{messageId}')
  .onCreate(async (snap, context) => {
    const message = snap.data();
    const receiverId = message.receiverId;
    const senderName = message.senderName;
    const payload = {
        notification: {
          title: `New message from ${senderName}`,
          body: message.text,
        },
      };

      await sendNotification(receiverId, payload);
  });
