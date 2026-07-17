from slowapi import Limiter
from slowapi.util import get_remote_address
from fastapi import Request

def get_real_client_ip(request: Request) -> str:
    # Check X-Forwarded-For first when running behind Nginx / Tailscale Funnel reverse proxy
    forwarded_for = request.headers.get("X-Forwarded-For")
    if forwarded_for:
        # Extract the original client IP rightmost/leftmost from header list
        return forwarded_for.split(",")[0].strip()
    real_ip = request.headers.get("X-Real-IP")
    if real_ip:
        return real_ip.strip()
    return get_remote_address(request)

limiter = Limiter(key_func=get_real_client_ip)
