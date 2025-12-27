const admin = require('firebase-admin');

// Get all products
exports.getAllProducts = async (req, res) => {
    try {
        const snapshot = await admin.firestore().collection('products').get();
        const products = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        res.status(200).json(products);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching products', error: error.message });
    }
};

// Add new product
exports.addProduct = async (req, res) => {
    try {
        const productData = req.body;
        const docRef = await admin.firestore().collection('products').add({
            ...productData,
            createdAt: admin.firestore.FieldValue.serverTimestamp()
        });
        res.status(201).json({ id: docRef.id, message: 'Product added successfully' });
    } catch (error) {
        res.status(500).json({ message: 'Error adding product', error: error.message });
    }
};

// Update product
exports.updateProduct = async (req, res) => {
    try {
        const { id } = req.params;
        const productData = req.body;
        await admin.firestore().collection('products').doc(id).update(productData);
        res.status(200).json({ message: 'Product updated successfully' });
    } catch (error) {
        res.status(500).json({ message: 'Error updating product', error: error.message });
    }
};

// Delete product
exports.deleteProduct = async (req, res) => {
    try {
        const { id } = req.params;
        await admin.firestore().collection('products').doc(id).delete();
        res.status(200).json({ message: 'Product deleted successfully' });
    } catch (error) {
        res.status(500).json({ message: 'Error deleting product', error: error.message });
    }
};
