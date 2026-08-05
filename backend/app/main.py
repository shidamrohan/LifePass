from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.v1.routes import auth, patient, reports, emergency, qr_codes, doctor
from app.models import Base
from app.database import engine
import os

# Create database tables
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="LifePass API",
    description="AI-Powered Emergency Health Identity Platform",
    version="1.0.0",
)

# CORS Middleware
origins = [
    "http://localhost:3000",
    "http://localhost:8080",
    "http://localhost:3001",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth.router)
app.include_router(patient.router)
app.include_router(reports.router)
app.include_router(emergency.router)
app.include_router(qr_codes.router)
app.include_router(doctor.router)


@app.get("/")
def read_root():
    return {
        "message": "Welcome to LifePass API",
        "version": "1.0.0",
        "docs": "/docs",
    }


@app.get("/health")
def health_check():
    return {"status": "healthy"}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=os.getenv("DEBUG", "True") == "True",
    )
