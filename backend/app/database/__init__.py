from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import NullPool
from dotenv import load_dotenv
import os

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./lifepass.db")


def create_db_engine():
    global DATABASE_URL
    try:
        if DATABASE_URL.startswith("sqlite"):
            eng = create_engine(
                DATABASE_URL, connect_args={"check_same_thread": False}
            )
        else:
            eng = create_engine(DATABASE_URL, poolclass=NullPool, echo=False)
        # Verify connection works
        with eng.connect() as conn:
            pass
        return eng
    except Exception as e:
        print(f"⚠️ Database connection ({DATABASE_URL}) failed: {e}")
        print("⚠️ Falling back to local SQLite database (lifepass.db)...")
        DATABASE_URL = "sqlite:///./lifepass.db"
        return create_engine(
            DATABASE_URL, connect_args={"check_same_thread": False}
        )


engine = create_db_engine()
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
