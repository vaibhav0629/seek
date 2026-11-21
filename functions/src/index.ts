
import {initializeApp} from "firebase-admin/app";
import {
  FieldValue,
  getFirestore,
} from "firebase-admin/firestore";
import {
  onCall,
  HttpsError,
  type CallableRequest,
} from "firebase-functions/v2/https";
import {setGlobalOptions} from "firebase-functions";

initializeApp();

const db = getFirestore();

setGlobalOptions({
  maxInstances: 10,
  region: "asia-southeast2",
});

type RsvpStatus = "going" | "waitlist" | "cancelled";

interface MeetInput {
  title?: unknown;
  clubId?: unknown;
  sport?: unknown;
  description?: unknown;
  startsAt?: unknown;
  venueName?: unknown;
  latitude?: unknown;
  longitude?: unknown;
  geohash?: unknown;
  maxPlayers?: unknown;
  fee?: unknown;
}

interface CallableData {
  meetId?: unknown;
  userId?: unknown;
  userName?: unknown;
  paid?: unknown;
  checkedIn?: unknown;
  meet?: unknown;
}

type Request = CallableRequest<CallableData>;

/**
 * Validates the authenticated Firebase user.
 * @param {Request} request Callable request.
 * @return {string} Authenticated user's UID.
 */
function requireAuth(request: Request): string {
  const uid = request.auth?.uid;

  if (!uid) {
    throw new HttpsError("unauthenticated", "Please sign in first.");
  }

  return uid;
}

/**
 * Validates a required string argument.
 * @param {unknown} value Value to validate.
 * @param {string} field Name of the field.
 * @return {string} Validated string.
 */
function requireString(value: unknown, field: string): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new HttpsError("invalid-argument", `${field} is required.`);
  }

  return value.trim();
}

/**
 * Creates an alert inside the current Firestore transaction.
 * @param {FirebaseFirestore.Transaction} transaction Firestore transaction.
 * @param {string} userId Alert recipient UID.
 * @param {string} meetId Related meet ID.
 * @param {string} type Alert type.
 * @param {string} title Alert title.
 * @param {string} message Alert message.
 * @return {void} Does not return a value.
 */
function addAlert(
  transaction: FirebaseFirestore.Transaction,
  userId: string,
  meetId: string,
  type: string,
  title: string,
  message: string,
): void {
  const alertRef = db.collection("meet_alerts").doc();

  transaction.set(alertRef, {
    userId,
    meetId,
    type,
    title,
    message,
    createdAt: FieldValue.serverTimestamp(),
    isRead: false,
  });
}

// CREATE MEET

export const createMeet = onCall(async (request: Request) => {
  const uid = requireAuth(request);
  const data = request.data.meet as MeetInput | undefined;

  if (!data || typeof data !== "object") {
    throw new HttpsError("invalid-argument", "Meet data is required.");
  }

  const title = requireString(data.title, "title");
  const clubId = requireString(data.clubId, "clubId");
  const sport = requireString(data.sport, "sport");
  const venueName = requireString(data.venueName, "venueName");

  const maxPlayers = Number(data.maxPlayers);
  const fee = Number(data.fee ?? 0);

  if (
    typeof data.startsAt !== "string" &&
    typeof data.startsAt !== "number"
  ) {
    throw new HttpsError("invalid-argument", "Invalid startsAt.");
  }

  const startsAt = new Date(data.startsAt);

  if (!Number.isFinite(maxPlayers) || maxPlayers < 1) {
    throw new HttpsError("invalid-argument", "Invalid maxPlayers.");
  }

  if (!Number.isFinite(fee) || fee < 0) {
    throw new HttpsError("invalid-argument", "Invalid fee.");
  }

  if (Number.isNaN(startsAt.getTime())) {
    throw new HttpsError("invalid-argument", "Invalid startsAt.");
  }

  const meetRef = db.collection("meets").doc();

  await meetRef.set({
    clubId,
    title,
    sport,
    description: typeof data.description === "string" ?
      data.description : "",
    startsAt,
    venueName,
    latitude: typeof data.latitude === "number" ?
      data.latitude : null,
    longitude: typeof data.longitude === "number" ?
      data.longitude : null,
    geohash: typeof data.geohash === "string" ?
      data.geohash : null,
    maxPlayers,
    fee,
    createdBy: uid,
    status: "upcoming",
    goingCount: 0,
    waitlistCount: 0,
    waitlistUserIds: [],
    createdAt: FieldValue.serverTimestamp(),
  });

  return {meetId: meetRef.id};
});

// JOIN MEET

export const joinMeet = onCall(async (request: Request) => {
  const uid = requireAuth(request);
  const meetId = requireString(request.data.meetId, "meetId");
  const userName = requireString(request.data.userName, "userName");

  const meetRef = db.collection("meets").doc(meetId);
  const rsvpRef = meetRef.collection("rsvps").doc(uid);

  return db.runTransaction(async (transaction) => {
    const meetSnapshot = await transaction.get(meetRef);
    const rsvpSnapshot = await transaction.get(rsvpRef);

    if (!meetSnapshot.exists) {
      throw new HttpsError("not-found", "Meet not found.");
    }

    if (rsvpSnapshot.exists) {
      const existing = rsvpSnapshot.data()!;

      if (
        existing.status === "going" ||
        existing.status === "waitlist"
      ) {
        return {status: existing.status as RsvpStatus};
      }
    }

    const meet = meetSnapshot.data()!;

    if (meet.status !== "upcoming") {
      throw new HttpsError(
        "failed-precondition",
        "This meet is not available for registration.",
      );
    }

    const goingCount = Number(meet.goingCount ?? 0);
    const maxPlayers = Number(meet.maxPlayers ?? 0);

    if (maxPlayers < 1) {
      throw new HttpsError(
        "failed-precondition",
        "Invalid meet capacity.",
      );
    }

    const status: RsvpStatus = goingCount >= maxPlayers ?
      "waitlist" : "going";

    const waitlist: string[] = Array.isArray(meet.waitlistUserIds) ?
      [...meet.waitlistUserIds] : [];

    transaction.set(rsvpRef, {
      userId: uid,
      meetId,
      userName,
      status,
      paid: false,
      checkedIn: false,
      joinedAt: FieldValue.serverTimestamp(),
      paidAt: null,
    });

    if (status === "going") {
      transaction.update(meetRef, {
        goingCount: FieldValue.increment(1),
      });

      addAlert(
        transaction,
        uid,
        meetId,
        "rsvpConfirmed",
        "RSVP Confirmed",
        "Your spot in the meet has been confirmed.",
      );
    } else {
      if (!waitlist.includes(uid)) {
        waitlist.push(uid);
      }

      transaction.update(meetRef, {
        waitlistCount: FieldValue.increment(1),
        waitlistUserIds: waitlist,
      });

      addAlert(
        transaction,
        uid,
        meetId,
        "waitlistJoined",
        "Added to Waitlist",
        "You have been added to the meet waitlist.",
      );
    }

    return {status};
  });
});

// LEAVE MEET AND PROMOTE WAITLIST

export const leaveMeet = onCall(async (request: Request) => {
  const uid = requireAuth(request);
  const meetId = requireString(request.data.meetId, "meetId");

  const meetRef = db.collection("meets").doc(meetId);
  const rsvps = meetRef.collection("rsvps");
  const currentRef = rsvps.doc(uid);

  return db.runTransaction(async (transaction) => {
    const meetSnapshot = await transaction.get(meetRef);
    const currentSnapshot = await transaction.get(currentRef);

    if (!meetSnapshot.exists || !currentSnapshot.exists) {
      return {success: true};
    }

    const current = currentSnapshot.data()!;

    if (
      current.status === "cancelled" ||
      !["going", "waitlist"].includes(current.status)
    ) {
      return {success: true};
    }

    const meet = meetSnapshot.data()!;

    const waitlist: string[] = Array.isArray(meet.waitlistUserIds) ?
      [...meet.waitlistUserIds] : [];

    const candidateSnapshots = await Promise.all(
      waitlist
        .filter((id) => id !== uid)
        .map((id) => transaction.get(rsvps.doc(id))),
    );

    let promotedId: string | null = null;
    let promotedRef: FirebaseFirestore.DocumentReference | null = null;

    for (const candidate of candidateSnapshots) {
      if (
        candidate.exists &&
        candidate.data()?.status === "waitlist"
      ) {
        promotedId = candidate.id;
        promotedRef = candidate.ref;
        break;
      }
    }

    transaction.update(currentRef, {
      status: "cancelled",
    });

    const updates: Record<string, unknown> = {};

    if (current.status === "going") {
      if (promotedId && promotedRef) {
        transaction.update(promotedRef, {
          status: "going",
        });

        updates.waitlistCount = FieldValue.increment(-1);
        updates.waitlistUserIds = waitlist.filter(
          (id) => id !== promotedId,
        );

        addAlert(
          transaction,
          promotedId,
          meetId,
          "waitlistPromoted",
          "You Got a Spot!",
          "A spot has opened up. You are now registered for this meet.",
        );
      } else {
        updates.goingCount = FieldValue.increment(-1);
      }
    } else {
      updates.waitlistCount = FieldValue.increment(-1);
      updates.waitlistUserIds = waitlist.filter(
        (id) => id !== uid,
      );
    }

    if (Object.keys(updates).length > 0) {
      transaction.update(meetRef, updates);
    }

    return {
      success: true,
      promotedUserId: promotedId,
    };
  });
});

// SET PAYMENT STATUS

export const setPaid = onCall(async (request: Request) => {
  const uid = requireAuth(request);
  const meetId = requireString(request.data.meetId, "meetId");
  const userId = requireString(request.data.userId, "userId");

  if (typeof request.data.paid !== "boolean") {
    throw new HttpsError("invalid-argument", "paid must be boolean.");
  }

  const meetRef = db.collection("meets").doc(meetId);
  const rsvpRef = meetRef.collection("rsvps").doc(userId);

  await db.runTransaction(async (transaction) => {
    const meetSnapshot = await transaction.get(meetRef);
    const rsvpSnapshot = await transaction.get(rsvpRef);

    if (!meetSnapshot.exists) {
      throw new HttpsError("not-found", "Meet not found.");
    }

    if (meetSnapshot.data()?.createdBy !== uid) {
      throw new HttpsError(
        "permission-denied",
        "Only the meet creator can update payment status.",
      );
    }

    if (!rsvpSnapshot.exists) {
      throw new HttpsError("not-found", "RSVP not found.");
    }

    const paid = request.data.paid as boolean;

    transaction.update(rsvpRef, {
      paid,
      paidAt: paid ? FieldValue.serverTimestamp() : null,
    });
  });

  return {success: true};
});

// SET CHECK-IN STATUS

export const setCheckedIn = onCall(async (request: Request) => {
  const uid = requireAuth(request);
  const meetId = requireString(request.data.meetId, "meetId");
  const userId = requireString(request.data.userId, "userId");

  if (typeof request.data.checkedIn !== "boolean") {
    throw new HttpsError(
      "invalid-argument",
      "checkedIn must be boolean.",
    );
  }

  const meetRef = db.collection("meets").doc(meetId);
  const rsvpRef = meetRef.collection("rsvps").doc(userId);

  await db.runTransaction(async (transaction) => {
    const meetSnapshot = await transaction.get(meetRef);
    const rsvpSnapshot = await transaction.get(rsvpRef);

    if (!meetSnapshot.exists) {
      throw new HttpsError("not-found", "Meet not found.");
    }

    if (meetSnapshot.data()?.createdBy !== uid) {
      throw new HttpsError(
        "permission-denied",
        "Only the meet creator can manage check-in.",
      );
    }

    if (!rsvpSnapshot.exists) {
      throw new HttpsError("not-found", "RSVP not found.");
    }

    const rsvp = rsvpSnapshot.data()!;
    const checkedIn = request.data.checkedIn as boolean;

    if (rsvp.status !== "going") {
      throw new HttpsError(
        "failed-precondition",
        "Only confirmed participants can check in.",
      );
    }

    if (rsvp.checkedIn === checkedIn) {
      return;
    }

    transaction.update(rsvpRef, {checkedIn});

    if (checkedIn) {
      addAlert(
        transaction,
        userId,
        meetId,
        "checkInConfirmed",
        "Check-in Confirmed",
        "Your check-in has been recorded successfully.",
      );
    }
  });

  return {success: true};
});
