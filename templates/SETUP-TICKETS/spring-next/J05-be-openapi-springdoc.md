# J05: BE OpenAPI spec via springdoc

## What
Add springdoc so the backend serves its live OpenAPI spec at `/v3/api-docs` (and Swagger UI at `/swagger-ui.html` in dev only).

## Why
The approved contract in `<project>-context/contracts/` is the source of truth. The live spec lets anyone check that the implementation still matches it, and feeds FE type generation (J09).

## Steps
1. Add to `pom.xml` (2.8.x line for Spring Boot 3.5):
   ```xml
   <dependency>
     <groupId>org.springdoc</groupId>
     <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
     <version>2.8.9</version>
   </dependency>
   ```
2. Disable the UI outside dev: `springdoc.swagger-ui.enabled: false` in the non-dev profiles; keep `/v3/api-docs` behind auth or dev-only as the security setup requires
3. Make sure the `ApiResponse` envelope and error shape appear in the spec (generic wrapper schemas)
4. Verify: `curl -s localhost:8080/v3/api-docs | head -c 200` returns JSON

## Idempotent check
```bash
cat "$BE_REPO/pom.xml" 2>/dev/null | grep -q "springdoc-openapi"
```

## Acceptance
- `/v3/api-docs` serves the spec in dev
- Swagger UI not exposed in non-dev profiles
- Committed
