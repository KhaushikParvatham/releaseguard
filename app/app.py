from flask import Flask, jsonify
import os
import time

app = Flask(__name__)

START_TIME = time.time()

REQUIRED_ENV_VARS = [
    "APP_ENV"
]


def perform_health_checks():
    checks = {}

    # Config validation
    missing = [var for var in REQUIRED_ENV_VARS if not os.getenv(var)]
    checks["config_valid"] = len(missing) == 0

    # Startup stability (avoid marking healthy too early)
    uptime = int(time.time() - START_TIME)
    checks["uptime_stable"] = uptime >= 5

    healthy = all(checks.values())

    return healthy, {
        "status": "healthy" if healthy else "unhealthy",
        "checks": checks,
        "uptime_seconds": uptime
    }


@app.route("/health", methods=["GET"])
def health():
    healthy, payload = perform_health_checks()
    return jsonify(payload), 200 if healthy else 503


@app.route("/", methods=["GET"])
def index():
    return jsonify({
        "service": "ReleaseGuard",
        "environment": os.getenv("APP_ENV", "undefined"),
        "message": "Application running"
    })


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=3000)
