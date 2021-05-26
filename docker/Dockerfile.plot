ARG sourceimage=develop
ARG imagename=freqtradeorg/freqtrade
FROM ${imagename}:${sourceimage}

# Install dependencies
COPY requirements-plot.txt /freqtrade/

RUN pip install -r requirements-plot.txt --user --no-cache-dir
