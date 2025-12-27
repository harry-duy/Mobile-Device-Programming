const express = require('express');
const admin = require('firebase-admin');
const cors = require('cors');
require('dotenv').config();

// Initialize Firebase Admin
// Note: You must provide serviceAccountKey.json in the backend folder
try {
    const serviceAccount = require('./serviceAccountKey.json');
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
    });
    console.log('Firebase Admin initialized');
} catch (error) {
    console.error('Error initializing Firebase Admin:', error.message);
    console.log('Please ensure serviceAccountKey.json exists in the backend folder.');
}

const app = express();
app.use(cors());
app.use(express.json());

// Routes
const authRoutes = require('./src/routes/authRoutes');
const productRoutes = require('./src/routes/productRoutes');
const categoryRoutes = require('./src/routes/categoryRoutes');

app.use('/api/auth', authRoutes);
app.use('/api/products', productRoutes);
app.use('/api/categories', categoryRoutes);

// Health check
app.get('/', (req, res) => res.send('Admin Backend API is running'));

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(\`Server is running on port \${PORT}\`);
});
