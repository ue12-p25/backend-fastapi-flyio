from fastapi import FastAPI

VERSION = "00"

app = FastAPI()


@app.get("/")
async def root():
    return dict(message="Hello FastAPI no fly.io !",
                version=VERSION)
