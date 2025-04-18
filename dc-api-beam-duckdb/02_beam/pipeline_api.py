from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Literal
import uvicorn
from pipeline import run_pipeline  # This imports the Beam pipeline

app = FastAPI()


# --------- Request Model ----------
class WeatherRequest(BaseModel):
    venue_id: str
    latitude: float
    longitude: float
    start_date: str  # Format: YYYY-MM-DD
    end_date: str    # Format: YYYY-MM-DD


# --------- API Route ----------
@app.post("/fetch-weather")
async def fetch_weather(req: WeatherRequest):
    try:
        run_pipeline(
            venue_id=req.venue_id,
            lat=req.latitude,
            lon=req.longitude,
            start_date=req.start_date,
            end_date=req.end_date
        )
        return {"status": "success", "message": "Weather data fetched and stored."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# --------- Main Entry Point ----------
if __name__ == "__main__":
    uvicorn.run("pipeline_api:app", host="0.0.0.0", port=8080, reload=True)
