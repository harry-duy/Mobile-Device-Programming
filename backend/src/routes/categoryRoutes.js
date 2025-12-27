const express = require('express');
const router = express.Router();
const categoryController = require('../controllers/categoryController');
const { verifyAdmin } = require('../middleware/authMiddleware');

router.get('/', categoryController.getAllCategories);
router.post('/', verifyAdmin, categoryController.addCategory);
router.delete('/:id', verifyAdmin, categoryController.deleteCategory);

module.exports = router;
