const jwt = require('jsonwebtoken');
const ACCESS_TOKEN_SECRET = process.env.ACCESS_TOKEN_SECRET;

function authenticateToken(req, res, next) {
  const authHeader = req.headers.authorization;

  const token = authHeader?.split(' ')[1];

  if (!token) return res.sendStatus(401);

  jwt.verify(token, ACCESS_TOKEN_SECRET, (err, user) => {
    if (err) {
      console.error("Token verification error:", err);
      return res.sendStatus(403);
    }
    req.user = user;
    next();
  });
}


function authorizeRoles(...roles) {
  return (req, res, next) => {
    if (!roles.includes(req.user?.role)) return res.sendStatus(403);
    next();
  };
}

module.exports = { authenticateToken, authorizeRoles };
