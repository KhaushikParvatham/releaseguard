# ---------- Base ----------
FROM python:3.12-slim

# ---------- Environment ----------
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# ---------- System setup ----------
RUN addgroup --system appgroup \
 && adduser --system --ingroup appgroup appuser

WORKDIR /app

# ---------- Dependencies ----------
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ---------- Application ----------
COPY app/ .

# ---------- Permissions ----------
RUN chown -R appuser:appgroup /app
USER appuser

# ---------- Runtime ----------
EXPOSE 3000

CMD ["python", "app.py"]

