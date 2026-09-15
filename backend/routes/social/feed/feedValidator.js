const FeedValidator = {

  validateFeedQuery(req, res, next) {
    const {
      page,
      limit,
    } = req.query;

    if (
      page !== undefined &&
      (
        !Number.isInteger(Number(page)) ||
        Number(page) < 1
      )
    ) {
      return res.status(400).json({
        success: false,
        error: "page must be a positive integer.",
      });
    }

    if (
      limit !== undefined &&
      (
        !Number.isInteger(Number(limit)) ||
        Number(limit) < 1
      )
    ) {
      return res.status(400).json({
        success: false,
        error: "limit must be a positive integer.",
      });
    }

    next();
  },

};

module.exports = FeedValidator;