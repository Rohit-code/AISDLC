# J01: BE Dockerfile — Maven wrapper multi-stage build

## What
Multi-stage Dockerfile for the Spring Boot backend: a JDK stage builds the jar with the Maven wrapper, a JRE stage runs it as a non-root user.

## Why
The wrapper pins the Maven version, so the image builds the same way as a laptop or CI. The runtime image carries only the JRE and the jar.

## Steps
1. Create `Dockerfile` in BE repo root:
   ```dockerfile
   # ── Build
   FROM eclipse-temurin:21-jdk AS build
   WORKDIR /build
   COPY mvnw pom.xml ./
   COPY .mvn .mvn
   RUN ./mvnw -q -B dependency:go-offline
   COPY src src
   RUN ./mvnw -q -B -DskipTests package && cp target/*.jar app.jar

   # ── Runtime
   FROM eclipse-temurin:21-jre
   WORKDIR /app
   RUN useradd --system --no-create-home app
   USER app
   COPY --from=build /build/app.jar app.jar
   EXPOSE 8080
   ENTRYPOINT ["java", "-jar", "/app/app.jar"]
   ```
2. Add `.dockerignore`:
   ```
   .git
   .env
   target
   .idea
   *.iml
   ```
3. Build test: `docker build -t <project>-be .` (tests run in the test step, not in the image build)
4. Commit

## Idempotent check
```bash
test -f "$BE_REPO/Dockerfile" && grep -q "mvnw" "$BE_REPO/Dockerfile"
```

## Acceptance
- Multi-stage Dockerfile at BE repo root, built with `./mvnw`
- Builds cleanly on fresh clone
- Runs as a non-root user
- `.dockerignore` prevents leaking `.env`
- Committed
