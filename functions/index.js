const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();
const db = admin.firestore();

// Simple in-memory rate limiter (for demo only)
const rateLimitWindowMs = 60*1000; const maxSwipesPerWindow = 30; const swipeTimestamps = {};

function isRateLimited(userId){ const now=Date.now(); if(!swipeTimestamps[userId]) swipeTimestamps[userId]=[]; swipeTimestamps[userId]=swipeTimestamps[userId].filter(ts=> now - ts <= rateLimitWindowMs); if(swipeTimestamps[userId].length>=maxSwipesPerWindow) return true; swipeTimestamps[userId].push(now); return false; }

// On swipe create -> check for mutual right swipe and create match
exports.onSwipeCreate = functions.firestore.document('swipes/{swipeId}').onCreate(async (snap, context) => {
  const swipe = snap.data(); const fromUserId = swipe.fromUserId; const toUserId = swipe.toUserId; const direction = swipe.direction || (swipe.liked? 'right':'left');

  if (isRateLimited(fromUserId)) { console.log('rate limited', fromUserId); return null; }
  if (direction !== 'right') return null;

  // Prevent duplicate existing match
  const existing = await db.collection('matches').where('user1Id', 'in', [fromUserId, toUserId]).where('user2Id', 'in', [fromUserId, toUserId]).limit(1).get();
  if (!existing.empty) return null;

  const mutual = await db.collection('swipes').where('fromUserId', '==', toUserId).where('toUserId', '==', fromUserId).where('direction', '==', 'right').limit(1).get();
  if (!mutual.empty) {
    const fromDoc = await db.collection('users').doc(fromUserId).get();
    const toDoc = await db.collection('users').doc(toUserId).get();
    const fromFree = fromDoc.exists ? fromDoc.data().freeMatch : false;
    const toFree = toDoc.exists ? toDoc.data().freeMatch : false;
    if (!fromFree && !toFree) return null;
    const matchRef = await db.collection('matches').add({ user1Id: fromUserId, user2Id: toUserId, matchedAt: admin.firestore.FieldValue.serverTimestamp() });
    const batch = db.batch();
    if (fromFree) batch.update(db.collection('users').doc(fromUserId), { freeMatch: false });
    if (toFree) batch.update(db.collection('users').doc(toUserId), { freeMatch: false });
    await batch.commit();
    const fromToken = fromDoc.data()?.fcmToken; const toToken = toDoc.data()?.fcmToken;
    const payload1 = { notification:{ title: 'You have a new match!', body: `You matched with ${toDoc.data()?.name || 'Someone'}` }, data:{ matchId: matchRef.id } };
    const payload2 = { notification:{ title: 'You have a new match!', body: `You matched with ${fromDoc.data()?.name || 'Someone'}` }, data:{ matchId: matchRef.id } };
    const promises = []; if (fromToken) promises.push(admin.messaging().sendToDevice(fromToken, payload1)); if (toToken) promises.push(admin.messaging().sendToDevice(toToken, payload2)); await Promise.all(promises);
  }
  return null;
});

// Callable to promote user to admin (only admins can call)
exports.promoteToAdmin = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Auth required');
  const callerUid = context.auth.uid; const targetUid = data.uid;
  if (!targetUid) throw new functions.https.HttpsError('invalid-argument', 'uid required');
  const callerDoc = await db.collection('users').doc(callerUid).get();
  if (!callerDoc.exists || callerDoc.data().role !== 'admin') throw new functions.https.HttpsError('permission-denied', 'Only admins');
  await db.collection('users').doc(targetUid).update({ role: 'admin' });
  return { success: true };
});

// Admin actions moved to adminActions.js and exported below
const adminActions = require('./adminActions');
exports.blockUser = adminActions.blockUser;
exports.deleteReport = adminActions.deleteReport;

// Bootstrap callable - protected by functions config secret
exports.promoteInitialAdmins = functions.https.onCall(async (data, context) => {
  const secret = functions.config().bootstrap?.secret || null;
  if (!data.secret || data.secret !== secret) throw new functions.https.HttpsError('permission-denied', 'Invalid secret');
  const uids = data.uids; if (!Array.isArray(uids) || uids.length===0) throw new functions.https.HttpsError('invalid-argument', 'uids array required');
  const batch = db.batch(); uids.forEach(uid => batch.update(db.collection('users').doc(uid), { role: 'admin' })); await batch.commit();
  return { success: true, promoted: uids.length };
});
