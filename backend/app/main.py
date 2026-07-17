from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from slowapi.middleware import SlowAPIMiddleware
from app.database import engine, Base
from app.routers import auth, products, checkout
from app.limiter import limiter

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Create tables on startup if not existing
    try:
        Base.metadata.create_all(bind=engine)
    except Exception as e:
        print(f"Warning: could not create tables on startup: {e}")
    yield

app = FastAPI(
    title="Gamified Virtual Shopping Application (Dopamine Booster) API",
    description="High-performance backend simulation with virtual currency and dopamine reward tracking.",
    version="1.0.0",
    lifespan=lifespan
)

app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)
app.add_middleware(SlowAPIMiddleware)

# Configure CORS securely for local development and Tailscale public funnels
app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"https://.*\.ts\.net|http://(localhost|127\.0\.0\.1)(:[0-9]+)?",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(products.router)
app.include_router(checkout.router)

@app.get("/health")
def health_check():
    return {"status": "ok", "dopamine_system": "online"}
