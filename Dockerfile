FROM python:3.9.2-slim-buster as base

# Setup env
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONFAULTHANDLER 1
ENV PATH=/root/.local/bin:$PATH

# Prepare environment
RUN mkdir /freqtrade
WORKDIR /freqtrade

# Install dependencies
FROM base as python-deps
RUN apt-get update \
    && apt-get -y install curl build-essential libssl-dev git \
    && apt-get clean \
    && pip install --upgrade pip

# Install TA-lib
COPY build_helpers/* /tmp/
RUN cd /tmp && /tmp/install_ta-lib.sh && rm -r /tmp/*ta-lib*
ENV LD_LIBRARY_PATH /usr/local/lib

# Install dependencies
COPY requirements.txt requirements-hyperopt.txt /freqtrade/
RUN  pip install --user --no-cache-dir numpy \
  && pip install --user --no-cache-dir -r requirements-hyperopt.txt

FROM python-deps as tests
COPY requirements-dev.txt requirements-plot.txt .coveragerc /freqtrade/
RUN pip install --user --no-cache-dir -r requirements-dev.txt
COPY . /freqtrade/
ENV PY_IGNORE_IMPORTMISMATCH 1
RUN mkdir -p user_data/strategies
RUN pytest --random-order --cov=freqtrade --cov-config=.coveragerc tests

# Copy dependencies to runtime-image
FROM base as runtime-image
COPY --from=python-deps /usr/local/lib /usr/local/lib
ENV LD_LIBRARY_PATH /usr/local/lib

COPY --from=python-deps /root/.local /root/.local



# Install and execute
COPY . /freqtrade/
RUN pip install -e . --no-cache-dir \
  && mkdir /freqtrade/user_data/ \
  && freqtrade install-ui

ENTRYPOINT ["freqtrade"]
# Default to trade mode
CMD [ "trade" ]
