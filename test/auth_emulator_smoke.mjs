import assert from 'node:assert/strict';

const projectId = 'fandom-verse-pocket-unzela';
const authHost = process.env.FIREBASE_AUTH_EMULATOR_HOST ?? '127.0.0.1:9099';
const firestoreHost =
  process.env.FIRESTORE_EMULATOR_HOST ?? '127.0.0.1:8080';
const authBase = `http://${authHost}/identitytoolkit.googleapis.com/v1`;
const firestoreBase =
  `http://${firestoreHost}/v1/projects/${projectId}/databases/(default)/documents`;

async function request(url, {method = 'GET', token, body} = {}) {
  const response = await fetch(url, {
    method,
    headers: {
      'Content-Type': 'application/json',
      ...(token ? {Authorization: `Bearer ${token}`} : {}),
    },
    body: body ? JSON.stringify(body) : undefined,
  });
  return {status: response.status, data: await response.json()};
}

async function signUp(email) {
  const result = await request(`${authBase}/accounts:signUp?key=emulator`, {
    method: 'POST',
    body: {email, password: 'StrongPassword1', returnSecureToken: true},
  });
  assert.equal(result.status, 200, JSON.stringify(result.data));
  return result.data;
}

const email = `fan-${Date.now()}@example.test`;
const newUser = await signUp(email);
const userDoc = `${firestoreBase}/users/${newUser.localId}`;
const profile = {
  fields: {
    uid: {stringValue: newUser.localId},
    displayName: {stringValue: 'Fan Test'},
    email: {stringValue: email},
    role: {stringValue: 'fan'},
    accountStatus: {stringValue: 'active'},
    selectedFandoms: {
      arrayValue: {values: [{stringValue: 'Gaming'}]},
    },
    badge: {stringValue: 'New Explorer'},
  },
};

const adminAttempt = await request(
  `${firestoreBase}/users?documentId=${newUser.localId}`,
  {
    method: 'POST',
    token: newUser.idToken,
    body: {
      fields: {...profile.fields, role: {stringValue: 'admin'}},
    },
  },
);
assert.equal(adminAttempt.status, 403, 'Fan cannot create an Admin profile');

const created = await request(
  `${firestoreBase}/users?documentId=${newUser.localId}`,
  {method: 'POST', token: newUser.idToken, body: profile},
);
assert.equal(created.status, 200, JSON.stringify(created.data));

const login = await request(
  `${authBase}/accounts:signInWithPassword?key=emulator`,
  {
    method: 'POST',
    body: {email, password: 'StrongPassword1', returnSecureToken: true},
  },
);
assert.equal(login.status, 200, JSON.stringify(login.data));
assert.equal(login.data.localId, newUser.localId);

const ownProfile = await request(userDoc, {token: login.data.idToken});
assert.equal(ownProfile.status, 200, JSON.stringify(ownProfile.data));

const completedProfile = await request(
  `${userDoc}?updateMask.fieldPaths=selectedFandoms`,
  {
    method: 'PATCH',
    token: login.data.idToken,
    body: {
      fields: {
        selectedFandoms: {
          arrayValue: {values: [{stringValue: 'Gaming'}, {stringValue: 'Anime'}]},
        },
      },
    },
  },
);
assert.equal(
  completedProfile.status,
  200,
  JSON.stringify(completedProfile.data),
);

const otherUser = await signUp(`other-${Date.now()}@example.test`);
const otherRead = await request(userDoc, {token: otherUser.idToken});
assert.equal(otherRead.status, 403, 'Another user cannot read the profile');

const roleChange = await request(`${userDoc}?updateMask.fieldPaths=role`, {
  method: 'PATCH',
  token: login.data.idToken,
  body: {fields: {role: {stringValue: 'admin'}}},
});
assert.equal(roleChange.status, 403, 'Fan cannot promote their own role');

console.log('Auth emulator smoke passed: registration, login, profile and role restrictions.');
