const express = require('express');
const router = express.Router();
const systemManager = require('../system/SystemManager');
const { authenticateToken, authorizeRoles } = require('../middlewares/authMiddleware');

const auth = [authenticateToken, authorizeRoles('admin', 'premium', 'freemium')];


router.post('/', auth, async (req, res) => {
  try {
    const post = await systemManager.createPost(req.user, req.body);
    res.status(201).json(post);
  } catch (err) {
    console.error(err.message);
    res.status(400).json({ error: err.message });
  }
});


router.post('/:id/like', auth, async (req, res) => {
  try {
    await systemManager.likePost(req.user, req.params.id);
    res.json({ message: 'Post liked' });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.delete('/:id', auth, async (req, res) => {
  try {
    await systemManager.deletePost(req.user, req.params.id);
    res.sendStatus(204);
  } catch (err) {
    res.status(403).json({ error: err.message });
  }
});


router.get('/:id/comments', auth, async (req, res) => {
  try {
    const comments = await systemManager.getCommentsByPost(req.params.id);
    res.json(comments);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch comments' });
  }
});

module.exports = router;