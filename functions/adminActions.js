const functions = require('firebase-functions');
const admin = require('firebase-admin');
const db = admin.firestore();

exports.blockUser = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Auth required');
  const callerUid = context.auth.uid; const targetUid = data.uid;
  if (!targetUid) throw new functions.https.HttpsError('invalid-argument', 'uid required');
  const callerDoc = await db.collection('users').doc(callerUid).get();
  if (!callerDoc.exists || callerDoc.data().role !== 'admin') throw new functions.https.HttpsError('permission-denied', 'Only admins');
  await db.collection('users').doc(targetUid).update({ blocked: true });
  return { success: true };
});

exports.deleteReport = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Auth required');
  const callerUid = context.auth.uid; const reportId = data.reportId;
  if (!reportId) throw new functions.https.HttpsError('invalid-argument', 'reportId required');
  const callerDoc = await db.collection('users').doc(callerUid).get();
  if (!callerDoc.exists || callerDoc.data().role !== 'admin') throw new functions.https.HttpsError('permission-denied', 'Only admins');
  await db.collection('reports').doc(reportId).delete();
  return { success: true };
});
