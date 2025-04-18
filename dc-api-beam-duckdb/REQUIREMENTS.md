# Requirements to run/deploy this project

1. python installed

2. docker installed

3. create venv from requirements:
   * python -m venv venv-beam
   * venv-beam/Scripts/activate (or Activate.ps1)
   * pip install -r requirements.txt

4. build and run docker image
   * docker-compose up --build

5. Test: Endpoint is on localhost:8080/fetch-weather
   * POST request with json payload, see docs: http://localhost:8080/docs#/
