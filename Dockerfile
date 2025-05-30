FROM dart:stable AS build

RUN apt update && apt install -y git unzip xz-utils curl && \
    git clone https://github.com/flutter/flutter.git /flutter && \
    /flutter/bin/flutter channel stable && \
    /flutter/bin/flutter upgrade && \
    /flutter/bin/flutter config --enable-web

ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:${PATH}"

WORKDIR /app
COPY . .

RUN flutter pub get && flutter build web

# ------------------------------------------

FROM python:3.12-slim

WORKDIR /app
COPY --from=build /app/build/web ./build/web

EXPOSE 5000

CMD ["python3", "-m", "http.server", "5000", "--directory", "build/web"]
