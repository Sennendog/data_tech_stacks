import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions
import requests
import duckdb
from datetime import datetime
import json


# ---------- Config ----------
DUCKDB_PATH = 'weather_data.duckdb'
TABLE_NAME = 'historical_weather'


# ---------- Utility Functions ----------
def fetch_weather_data(params):
    """Calls Open-Meteo API and returns parsed hourly weather data."""
    lat, lon, start_date, end_date = params['lat'], params['lon'], params['start_date'], params['end_date']
    url = (
        f"https://archive-api.open-meteo.com/v1/archive?"
        f"latitude={lat}&longitude={lon}&start_date={start_date}&end_date={end_date}"
        f"&hourly=temperature_2m,relative_humidity_2m,rain,showers,snowfall,snow_depth,cloud_cover,visibility,wind_speed_10m"
        f"&timezone=UTC"
    )
    response = requests.get(url)
    data = response.json()
    
    #print(data)

    # Flatten and structure the data
    result = []
    for i, timestamp in enumerate(data['hourly']['time']):
        result.append({
            'venue_id': params['venue_id'],
            'timestamp': timestamp,
            'temperature_2m': data['hourly'].get('temperature_2m', [None])[i],
            'relative_humidity_2m': data['hourly'].get('relative_humidity_2m', [None])[i],
            'rain': data['hourly'].get('rain', [None])[i],
            'showers': data['hourly'].get('showers', [None])[i],
            'snowfall': data['hourly'].get('snowfall', [None])[i],
            'snow_depth': data['hourly'].get('snow_depth', [None])[i],
            'cloud_cover': data['hourly'].get('cloud_cover', [None])[i],
            'visibility': data['hourly'].get('visibility', [None])[i],
            'wind_speed_10m': data['hourly'].get('wind_speed_10m', [None])[i]
        })
    return result


def write_to_duckdb(records):
    """Writes records to DuckDB."""
    conn = duckdb.connect(DUCKDB_PATH)
    conn.execute(f"""
        CREATE TABLE IF NOT EXISTS {TABLE_NAME} (
            venue_id VARCHAR,
            timestamp TIMESTAMP,
            temperature_2m FLOAT,
            relative_humidity_2m FLOAT,
            rain FLOAT,
            showers FLOAT,
            snowfall FLOAT,
            snow_depth FLOAT,
            cloud_cover FLOAT,
            visibility FLOAT,
            wind_speed_10m FLOAT
        )
    """)
    for row in records:
        placeholders = ', '.join('?' * len(row))
        columns = ', '.join(row.keys())
        values = tuple(row.values())
        conn.execute(f"INSERT INTO {TABLE_NAME} ({columns}) VALUES ({placeholders})", values)
    conn.close()


# ---------- Beam Pipeline ----------
def run_pipeline(venue_id, lat, lon, start_date, end_date):
    options = PipelineOptions()
    
    with beam.Pipeline(options=options) as p:
        (
            p
            | "Create Params" >> beam.Create([{
                'venue_id': venue_id,
                'lat': lat,
                'lon': lon,
                'start_date': start_date,
                'end_date': end_date
            }])
            | "Fetch Weather Data" >> beam.FlatMap(fetch_weather_data)
            | "Transform" >> beam.combiners.ToList()
            | "Output number of records to console" >> beam.Map(lambda records: (print(f"Number of records inserted: {len(records)}"), records)[1])
            | "write to duckdb" >> beam.Map(lambda records: write_to_duckdb(records))
            #| "Output to Console" >> beam.Map(lambda x: print(json.dumps(x, indent=2)))
        ) # type: ignore


# ---------- Example Invocation ----------
if __name__ == '__main__':
    venue_id, lat, lon, start_date, end_date = sys.argv[1:6]
    run_pipeline(venue_id, float(lat), float(lon), start_date, end_date)

    print(f"Pipeline completed for venue_id: {venue_id}, lat: {lat}, lon: {lon}, start_date: {start_date}, end_date: {end_date}")
    print(f"Data written to {DUCKDB_PATH} table {TABLE_NAME}")
