importScripts("https://www.gstatic.com/firebasejs/10.0.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.0.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyAOzh2wfS-Wik0T5tvpLKHnfKpBzFY9_ns",
  appId: "1:576999197569:web:15c587142d7af6a978b680",
  messagingSenderId: "576999197569",
  projectId: "ssh-me12",
  authDomain: "ssh-me12.firebaseapp.com",
  storageBucket: "ssh-me12.firebasestorage.app",
  measurementId: "G-N2D96KHSGG",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log("[firebase-messaging-sw.js] Received background message ", payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: "/icons/Icon-192.png",
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
