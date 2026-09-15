const express = require('express');
const router = express.Router();
const systemManager = require('../system/SystemManager');
const { authenticateToken, authorizeRoles } = require('../middlewares/authMiddleware');

const auth = [authenticateToken, authorizeRoles('admin', 'premium', 'freemium')];


router.post('/users-communities', auth, async (req, res) => {
  try {
    const { query, types } = req.body;
    const userId = req.user.id;

    const results = await systemManager.searchUsersAndCommunities(userId, query, types);
    res.status(200).json(results);
  } catch (error) {
    console.error('Search error:', error);
    res.status(500).json({ error: 'Search failed' });
  }
});


router.post('/hotels', auth, async (req, res) => {
  try {
    const filters = req.body;
    const results = await systemManager.searchResidences(filters);
    res.status(200).json(results);
  } catch (error) {
    console.error('Search error:', error);
    res.status(500).json({ error: 'Search failed' });
  }
});


router.post('/restaurants', auth, async (req, res) => {
  try {
    const filters = req.body;
    const results = await systemManager.searchRestaurants(filters);
    res.status(200).json(results);
  } catch (error) {
    console.error('Search error:', error);
    res.status(500).json({ error: 'Search failed' });
  }
});


router.post('/activities', auth, async (req, res) => {
  try {
    const filters = req.body;
    const results = await systemManager.searchActivities(filters);
    res.status(200).json(results);
  } catch (error) {
    console.error('Search error:', error);
    res.status(500).json({ error: 'Search failed' });
  }
});

module.exports = router;