// scripts/seed_firestore.js
// Run: node scripts/seed_firestore.js
// Requires: npm install firebase-admin

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json'); // Your Firebase service account

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

const reels = [
  {
    videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    thumbnailUrl: 'https://picsum.photos/seed/reel1/720/1280',
    username: 'nature_vibes',
    avatarUrl: 'https://i.pravatar.cc/150?img=1',
    caption: '🌿 A peaceful morning in the forest — nature never disappoints. #nature #morning',
    audioName: 'Forest Sounds - Original',
    likesCount: 12400,
    commentsCount: 843,
    sharesCount: 312,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    thumbnailUrl: 'https://picsum.photos/seed/reel2/720/1280',
    username: 'tech_creator',
    avatarUrl: 'https://i.pravatar.cc/150?img=5',
    caption: '🚀 Just shipped my latest Flutter app — took 2 weeks but worth it. Open source link in bio!',
    audioName: 'Lofi Study Beat - ChillHop',
    likesCount: 8760,
    commentsCount: 420,
    sharesCount: 198,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    thumbnailUrl: 'https://picsum.photos/seed/reel3/720/1280',
    username: 'travel_diary',
    avatarUrl: 'https://i.pravatar.cc/150?img=9',
    caption: '✈️ Tokyo at 3AM hits different. The city never sleeps and neither do I 🌃',
    audioName: 'City Lights - R&B Mix',
    likesCount: 34200,
    commentsCount: 2100,
    sharesCount: 880,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    thumbnailUrl: 'https://picsum.photos/seed/reel4/720/1280',
    username: 'fitness_guru',
    avatarUrl: 'https://i.pravatar.cc/150?img=12',
    caption: '💪 30-day challenge results: this is what consistency looks like. No excuses.',
    audioName: 'Pump It Up - Workout Beats',
    likesCount: 55000,
    commentsCount: 3400,
    sharesCount: 1200,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
    thumbnailUrl: 'https://picsum.photos/seed/reel5/720/1280',
    username: 'foodie_world',
    avatarUrl: 'https://i.pravatar.cc/150?img=20',
    caption: '🍜 Homemade ramen from scratch. This took 8 hours but tasted like heaven 🙏',
    audioName: 'Cooking with Jazz - Original',
    likesCount: 21000,
    commentsCount: 1050,
    sharesCount: 654,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
];

async function seed() {
  console.log('Seeding Firestore with reels...');
  const batch = db.batch();

  for (const reel of reels) {
    const ref = db.collection('reels').doc();
    batch.set(ref, reel);
    console.log(`  → Added reel: ${reel.username}`);
  }

  await batch.commit();
  console.log('✅ Firestore seeded successfully!');
  process.exit(0);
}

seed().catch((err) => {
  console.error('❌ Seed failed:', err);
  process.exit(1);
});
