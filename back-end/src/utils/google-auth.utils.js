import { applicationDefault, cert, getApps, initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import runtimeConfig from '../config/runtime.js';
import { toAppError } from '../services/common.service.js';

function normalizePrivateKey(value) {
  return String(value || '').replace(/\\n/g, '\n').trim();
}

function buildFirebaseCredentialConfig() {
  const serviceAccount = runtimeConfig.firebase.serviceAccountJson;
  if (
    serviceAccount &&
    typeof serviceAccount === 'object' &&
    !Array.isArray(serviceAccount)
  ) {
    const normalizedServiceAccount = {
      projectId:
        serviceAccount.projectId || serviceAccount.project_id || undefined,
      clientEmail:
        serviceAccount.clientEmail || serviceAccount.client_email || undefined,
      privateKey: normalizePrivateKey(
        serviceAccount.privateKey || serviceAccount.private_key
      )
    };

    if (
      normalizedServiceAccount.projectId &&
      normalizedServiceAccount.clientEmail &&
      normalizedServiceAccount.privateKey
    ) {
      return {
        credential: cert(normalizedServiceAccount),
        projectId: normalizedServiceAccount.projectId
      };
    }

    if (normalizedServiceAccount.projectId) {
      return {
        credential: applicationDefault(),
        projectId: normalizedServiceAccount.projectId
      };
    }
  }

  const privateKey = normalizePrivateKey(runtimeConfig.firebase.privateKey);
  if (
    runtimeConfig.firebase.projectId &&
    runtimeConfig.firebase.clientEmail &&
    privateKey
  ) {
    return {
      credential: cert({
        projectId: runtimeConfig.firebase.projectId,
        clientEmail: runtimeConfig.firebase.clientEmail,
        privateKey
      }),
      projectId: runtimeConfig.firebase.projectId
    };
  }

  if (runtimeConfig.firebase.projectId) {
    return {
      credential: applicationDefault(),
      projectId: runtimeConfig.firebase.projectId
    };
  }

  return null;
}

function getFirebaseApp() {
  const existingApp = getApps()[0];
  if (existingApp) {
    return existingApp;
  }

  const config = buildFirebaseCredentialConfig();
  if (!config) {
    throw toAppError(
      'Authentification Google non configuree sur le serveur',
      503,
      'GOOGLE_AUTH_NOT_CONFIGURED'
    );
  }

  return initializeApp(config);
}

export function isGoogleAuthConfigured() {
  return buildFirebaseCredentialConfig() !== null;
}

export async function verifyGoogleIdToken(idToken) {
  if (!isGoogleAuthConfigured()) {
    throw toAppError(
      'Authentification Google non configuree sur le serveur',
      503,
      'GOOGLE_AUTH_NOT_CONFIGURED'
    );
  }

  try {
    const payload = await getAuth(getFirebaseApp()).verifyIdToken(idToken);
    const subject = payload?.uid || payload?.sub;

    if (!subject) {
      throw toAppError('Token Google invalide', 401, 'INVALID_GOOGLE_TOKEN');
    }

    if (payload.firebase?.sign_in_provider !== 'google.com') {
      throw toAppError(
        'Ce jeton Firebase ne provient pas d une connexion Google',
        401,
        'INVALID_GOOGLE_TOKEN'
      );
    }

    if (!payload.email) {
      throw toAppError(
        'Votre compte Google ne fournit pas d adresse email exploitable',
        400,
        'GOOGLE_EMAIL_REQUIRED'
      );
    }

    return {
      sub: subject,
      email: String(payload.email).trim().toLowerCase(),
      email_verified: Boolean(payload.email_verified),
      given_name: payload.given_name || null,
      family_name: payload.family_name || null,
      name: payload.name || null,
      picture: payload.picture || null
    };
  } catch (error) {
    if (error?.code) {
      throw error;
    }

    throw toAppError(
      'Token Google invalide ou expire',
      401,
      'INVALID_GOOGLE_TOKEN'
    );
  }
}
