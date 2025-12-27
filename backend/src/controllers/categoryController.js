const admin = require('firebase-admin');

// Get all categories
exports.getAllCategories = async (req, res) => {
    try {
        const snapshot = await admin.firestore().collection('categories').get();
        const categories = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        res.status(200).json(categories);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching categories', error: error.message });
    }
};

// Add category
exports.addCategory = async (req, res) => {
    try {
        const { name } = req.body;
        const docRef = await admin.firestore().collection('categories').add({ name });
        res.status(201).json({ id: docRef.id, message: 'Category added successfully' });
    } catch (error) {
        res.status(500).json({ message: 'Error adding category', error: error.message });
    }
};

// Delete category
exports.deleteCategory = async (req, res) => {
    try {
        const { id } = req.params;
        await admin.firestore().collection('categories').doc(id).delete();
        res.status(200).json({ message: 'Category deleted successfully' });
    } catch (error) {
        res.status(500).json({ message: 'Error deleting category', error: error.message });
    }
};
