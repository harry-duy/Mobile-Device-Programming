const express = require('express');
const router = express.Router();
const productController = require('../controllers/productController');
const { verifyAdmin } = require('../middleware/authMiddleware');

router.get('/', productController.getAllProducts);
router.post('/', verifyAdmin, productController.addProduct);
router.put('/:id', verifyAdmin, productController.updateProduct);
router.delete('/:id', verifyAdmin, productController.deleteProduct);

module.exports = router;
