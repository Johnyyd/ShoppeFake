import urllib.parse
from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker
from app.config import settings

if settings.USE_TEST_SQLITE:
    SQLALCHEMY_DATABASE_URL = "sqlite:///./test_shoppe.db"
    engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
else:
    # PyMSSQL URL construction for reliable SQL Server connection without complex ODBC DSN setups
    pwd_encoded = urllib.parse.quote_plus(settings.DB_PASSWORD)
    try:
        # Auto-create ShoppeDB via master if it does not exist yet inside SQL Server
        master_url = f"mssql+pymssql://{settings.DB_USER}:{pwd_encoded}@{settings.DB_SERVER}:{settings.DB_PORT}/master"
        master_engine = create_engine(master_url, pool_pre_ping=True)
        with master_engine.connect() as conn:
            from sqlalchemy import text
            import re
            if not re.match(r'^[a-zA-Z0-9_]+$', settings.DB_NAME):
                raise ValueError(f"Invalid database name: {settings.DB_NAME}")
            conn.execute(text(f"IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = '{settings.DB_NAME}') CREATE DATABASE [{settings.DB_NAME}]"))
            conn.commit()
    except Exception:
        pass

    SQLALCHEMY_DATABASE_URL = f"mssql+pymssql://{settings.DB_USER}:{pwd_encoded}@{settings.DB_SERVER}:{settings.DB_PORT}/{settings.DB_NAME}"
    try:
        engine = create_engine(SQLALCHEMY_DATABASE_URL, pool_pre_ping=True)
        with engine.connect() as conn:
            pass
    except Exception:
        # Fallback to local SQLite when PyMSSQL/SQL Server connection fails locally during tests/dev setup
        engine = create_engine("sqlite:///./local_shoppe.db", connect_args={"check_same_thread": False})

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
