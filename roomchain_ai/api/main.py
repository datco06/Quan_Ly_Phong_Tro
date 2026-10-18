"""HTTP entry point; business AI endpoints will be added separately."""

from fastapi import FastAPI

app = FastAPI(title="RoomChain AI", version="0.1.0")


@app.get("/health", tags=["health"])
def health() -> dict[str, str]:
    return {"status": "ok", "service": "roomchain_ai"}
