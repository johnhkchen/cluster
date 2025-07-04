from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List
import uvicorn

app = FastAPI(title="Demo Backend API", version="1.0.0")

# Enable CORS for frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure appropriately for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class HealthResponse(BaseModel):
    status: str
    python_version: str
    timestamp: str

class ItemResponse(BaseModel):
    id: int
    name: str
    type: str
    location: str
    status: str
    last_updated: str

# Sample data
items_db = [
    {
        "id": 1, 
        "name": "Jetson Orin NX", 
        "type": "edge-compute",
        "location": "Edge Site A",
        "status": "online",
        "last_updated": "2025-01-04T12:00:00Z"
    },
    {
        "id": 2, 
        "name": "Raspberry Pi 5", 
        "type": "edge-sensor",
        "location": "Edge Site B", 
        "status": "online",
        "last_updated": "2025-01-04T12:00:00Z"
    },
    {
        "id": 3, 
        "name": "K3s Cloud Cluster", 
        "type": "cloud-cluster",
        "location": "US-East-1",
        "status": "healthy",
        "last_updated": "2025-01-04T12:00:00Z"
    },
]

@app.get("/health", response_model=HealthResponse)
async def health_check():
    import sys
    from datetime import datetime
    return HealthResponse(
        status="healthy",
        python_version=f"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}",
        timestamp=datetime.now().isoformat()
    )

@app.get("/items", response_model=List[ItemResponse])
async def get_items():
    return items_db

@app.get("/api/items", response_model=List[ItemResponse])
async def get_items_api():
    return items_db

@app.get("/api/items/{item_id}", response_model=ItemResponse)
async def get_item(item_id: int):
    item = next((item for item in items_db if item["id"] == item_id), None)
    if item:
        return item
    return {"error": "Item not found"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
