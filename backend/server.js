require("dotenv").config();

const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const helmet = require("helmet");
const compression = require("compression");
const mongoSanitize = require("express-mongo-sanitize");
const rateLimit = require("express-rate-limit");
const morgan = require("morgan");
const { randomUUID } = require("crypto");

const app = express();


// ============================================================================
// Routes
// ============================================================================

// ── Authentication ──────────────────────────────────────────────────────────

const authRoutes =
    require("./routes/auth/authRoutes");


// ── Administration ──────────────────────────────────────────────────────────

const adminRoutes =
    require("./routes/admin/adminRoutes");


// ── User ──────────────────────────────────────────────────────────


const userRoutes =
    require("./routes/user/userRoutes");

// ── AI ──────────────────────────────────────────────────────────

const aiRoutes =
  require("./routes/ai/aiRoutes");



// ── Social ──────────────────────────────────────────────────────────────────

const friendRoutes =
    require("./routes/social/friend/friendRoutes");

const requestRoutes =
    require("./routes/social/request/requestRoutes");

const feedRoutes =
    require("./routes/social/feed/feedRoutes");

const postRoutes =
    require("./routes/social/feed/post/postRoutes");

const commentRoutes =
    require("./routes/social/feed/post/comment/commentRoutes");

const communityRoutes =
    require("./routes/social/community/communityRoutes");

const messageRoutes =
    require("./routes/social/messaging/messagingRoutes");


// ── Notifications ──────────────────────────────────────────────────────────

const notificationRoutes =
    require("./routes/notification/notificationRoutes");


// ── Search ──────────────────────────────────────────────────────────────────

const searchRoutes =
    require("./routes/search/searchRoutes");


// ── Discovery / domain resources ────────────────────────────────────────────

const residenceRoutes =
    require("./routes/residence/residenceRoutes");

const restaurantRoutes =
    require("./routes/restaurant/restaurantRoutes");

const activityRoutes =
    require("./routes/activity/activityRoutes");

    const itineraryRoutes =
    require("./routes/itinerary/itineraryRoutes");


// ============================================================================
// Middlewares
// ============================================================================

const analyticsMiddleware =
    require("./middlewares/analyticsMiddleware");

const errorHandler =
    require("./middlewares/errorHandler");

const notFoundHandler =
    require("./middlewares/notFoundHandler");


// ============================================================================
// Security
// ============================================================================

app.use(helmet());

app.use(mongoSanitize());

app.use(
    cors({
        origin:
            process.env.ALLOWED_ORIGINS?.split(",")
            || "*",

        credentials: true,

        optionsSuccessStatus: 200,
    })
);

app.use(
    express.json({
        limit: "10mb",
    })
);

app.use(
    express.urlencoded({
        extended: true,
        limit: "10mb",
    })
);

app.use(compression());


// ============================================================================
// Logging
// ============================================================================

app.use(
    morgan(
        process.env.NODE_ENV === "development"
            ? "dev"
            : "combined"
    )
);


// ============================================================================
// Rate limiting
// ============================================================================

const limiter = rateLimit({

    windowMs:
        Number(
            process.env.RATE_LIMIT_WINDOW_MS
        ) || 15 * 60 * 1000,

    max:
        Number(
            process.env.RATE_LIMIT_MAX_REQUESTS
        ) || 100,

    message:
        "Too many requests. Please try again later.",

    standardHeaders: true,

    legacyHeaders: false,
});

app.use("/api", limiter);


// ============================================================================
// MongoDB
// ============================================================================

const mongoURI =
    process.env.MONGO_URI
    || "mongodb://localhost:27017/TsafiraUsers";

mongoose
    .connect(mongoURI)
    .then(() => {

        console.log("✓ Connected to MongoDB");

    })
    .catch((err) => {

        console.error(
            "MongoDB connection failed."
        );

        console.error(err);

        process.exit(1);
    });


// ============================================================================
// Request ID
// ============================================================================

app.use((req, res, next) => {

    req.requestId = randomUUID();

    next();
});


// ============================================================================
// Analytics
// ============================================================================

app.use(analyticsMiddleware);


// ============================================================================
// Health
// ============================================================================

app.get(
    "/api/health",
    (req, res) => {

        return res.status(200).json({

            success: true,

            data: {

                status: "OK",

                timestamp:
                    new Date().toISOString(),

                environment:
                    process.env.NODE_ENV
                    || "development",

                uptime:
                    process.uptime(),

            },

        });
    }
);


// ============================================================================
// API Routes
// ============================================================================

// ── Authentication ──────────────────────────────────────────────────────────

app.use(
    "/api/auth",
    authRoutes
);


// ── AI ──────────────────────────────────────────────────────────

app.use(
  "/api/ai",
  aiRoutes
);


// ── Social ──────────────────────────────────────────────────────────────────

app.use(
    "/api/friends",
    friendRoutes
);

app.use(
    "/api/requests",
    requestRoutes
);

app.use(
    "/api/feed",
    feedRoutes
);

app.use(
    "/api/posts",
    postRoutes
);

app.use(
    "/api/comments",
    commentRoutes
);

app.use(
    "/api/communities",
    communityRoutes
);

app.use("/api", messageRoutes);


// ── Notifications ──────────────────────────────────────────────────────────

app.use(
    "/api/notifications",
    notificationRoutes
);


// ── Search ──────────────────────────────────────────────────────────────────

app.use(
    "/api/search",
    searchRoutes
);


// ── Residences ──────────────────────────────────────────────────────────────

app.use(
    "/api/residences",
    residenceRoutes
);


// ── Restaurants ─────────────────────────────────────────────────────────────

app.use(
    "/api/restaurants",
    restaurantRoutes
);


// ── Activities ──────────────────────────────────────────────────────────────

app.use(
    "/api/activities",
    activityRoutes
);

app.use(
    "/api/itineraries",
    itineraryRoutes
);


// ── Administration ──────────────────────────────────────────────────────────

app.use(
    "/api/admin",
    adminRoutes
);

// ── User ──────────────────────────────────────────────────────────

app.use(
    "/api/users",
    userRoutes
);


// ============================================================================
// 404
// ============================================================================

app.use(notFoundHandler);


// ============================================================================
// Global error handler
// ============================================================================

app.use(errorHandler);


// ============================================================================
// Server
// ============================================================================

const PORT =
    process.env.PORT || 8000;

const server =
    app.listen(
        PORT,
        "0.0.0.0",
        () => {

            console.log(
                "=".repeat(60)
            );

            console.log(
                `Server running on port ${PORT}`
            );

            console.log(
                `Environment: ${
                    process.env.NODE_ENV
                    || "development"
                }`
            );

            console.log(
                "=".repeat(60)
            );
        }
    );


// ============================================================================
// Graceful shutdown
// ============================================================================

process.on(
    "SIGTERM",
    () => {

        console.log(
            "SIGTERM received."
        );

        server.close(() => {

            console.log(
                "HTTP server closed."
            );

            mongoose.connection.close(
                false,
                () => {

                    console.log(
                        "MongoDB connection closed."
                    );

                    process.exit(0);
                }
            );
        });
    }
);


module.exports = app;