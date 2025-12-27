const admin = require('firebase-admin');

exports.login = async (req, res) => {
    const { idToken } = req.body;

    if (!idToken) {
        return res.status(400).json({ message: 'ID Token is required' });
    }

    try {
        const decodedToken = await admin.auth().verifyIdToken(idToken);
        const uid = decodedToken.uid;

        const userDoc = await admin.firestore().collection('users').doc(uid).get();
        
        if (!userDoc.exists || userDoc.data().role !== 'admin') {
            return res.status(403).json({ message: 'Access denied. Not an admin.' });
        }

        res.status(200).json({
            message: 'Login successful',
            user: {
                uid: uid,
                email: decodedToken.email,
                role: userDoc.data().role
            }
        });
    } catch (error) {
        res.status(401).json({ message: 'Invalid token', error: error.message });
    }
};
