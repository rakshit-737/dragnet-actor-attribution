# DRAGNET - slim, non-root image. Runtime is stdlib-only; the API and signing extras are included.
FROM python:3.14-slim@sha256:f85c5697265c178cc6887276c55fe16cf3d14ca35c3df6a5eab3b360534a55d2 AS build
WORKDIR /src
COPY pyproject.toml README.md LICENSE ./
COPY dragnet ./dragnet
RUN pip wheel --no-cache-dir --wheel-dir /wheels ".[api,sign]"

FROM python:3.14-slim@sha256:f85c5697265c178cc6887276c55fe16cf3d14ca35c3df6a5eab3b360534a55d2
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1 DRAGNET_DATA=/data
RUN useradd --create-home --uid 10001 dragnet && mkdir /data && chown dragnet /data
COPY --from=build /wheels /wheels
RUN pip install --no-cache-dir /wheels/*.whl && rm -rf /wheels
WORKDIR /app
USER dragnet
LABEL org.opencontainers.image.source="https://github.com/rakshit-737/dragnet-actor-attribution" \
      org.opencontainers.image.description="Evidence-to-actor attribution with ACH and false-flag reasoning" \
      org.opencontainers.image.licenses="MIT"
ENTRYPOINT ["dragnet"]
CMD ["demo"]
