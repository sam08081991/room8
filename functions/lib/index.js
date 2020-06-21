"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendToDevice = exports.sendToTopic = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
const db = admin.firestore();
const fcm = admin.messaging();
exports.sendToTopic = functions.firestore
    .document('puppies/{puppyId}')
    .onCreate(async (snapshot) => {
    const puppy = snapshot.data();
    const payload = {
        notification: {
            title: 'New Puppy!',
            body: `${puppy.name} is ready for adoption`,
            icon: 'your-icon-url',
            click_action: 'FLUTTER_NOTIFICATION_CLICK'
        }
    };
    return fcm.sendToTopic('puppies', payload);
});
exports.sendToDevice = functions.firestore
    .document('orders/{orderId}')
    .onCreate(async (snapshot) => {
    const order = snapshot.data();
    const querySnapshot = await db
        .collection('users')
        .doc(order.seller)
        .collection('tokens')
        .get();
    const tokens = querySnapshot.docs.map(snap => snap.id);
    const payload = {
        notification: {
            title: 'New Order!',
            body: `you sold a ${order.product} for ${order.total}`,
            icon: 'your-icon-url',
            click_action: 'FLUTTER_NOTIFICATION_CLICK'
        }
    };
    return fcm.sendToDevice(tokens, payload);
});
//# sourceMappingURL=index.js.map