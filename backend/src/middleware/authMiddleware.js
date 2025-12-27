const admin = require('firebase-admin');

exports.verifyAdmin = async (req, res, next) => {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ message: 'Unauthorized: No token provided' });
    }

    const idToken = authHeader.split('Bearer ')[1];

    try {
        const decodedToken = await admin.auth().verifyIdToken(idToken);
        const userDoc = await admin.firestore().collection('users').doc(decodedToken.uid).get();

        if (!userDoc.exists || userDoc.data().role !== 'admin') {
            return res.status(403).json({ message: 'Forbidden: Admin access required' });
        }

        req.user = decodedToken;
        next();
    } catch (error) {
        res.status(401).json({ message: 'Invalid or expired token' });
    }
};
