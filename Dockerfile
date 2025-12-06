# 1. 빌드 단계 (Build Stage)
# Spring Boot 애플리케이션을 빌드하기 위해 Gradle이 설치된 환경을 사용합니다.
FROM gradle:8.14-jdk17-ubi-minimal AS build

# 작업 디렉터리를 설정합니다.
WORKDIR /app

# Gradle Wrapper 파일과 설정 파일을 복사합니다.
COPY backend/gradlew .
COPY backend/gradle/ /app/gradle/
COPY backend/build.gradle backend/settings.gradle /app/

# 의존성 다운로드 및 빌드를 위해 소스 코드를 복사합니다.
COPY backend/src /app/src

# 실행 가능한 JAR 파일을 빌드합니다. (build/libs/justaday-0.0.1-SNAPSHOT.jar 생성)
RUN ./gradlew clean build -x test

# ----------------------------------------------------

# 2. 실행 단계 (Production Stage)
# 가볍고 보안에 유리한 JRE 환경 (Java Runtime Environment)을 기반으로 이미지를 만듭니다.
FROM eclipse-temurin:17-jdk

# JAR 파일 이름을 변수로 설정합니다. 빌드 시 생성된 JAR 파일 이름과 일치해야 합니다.
ARG JAR_FILE_NAME=justaday-0.0.1-SNAPSHOT.jar

# Spring Boot 애플리케이션이 사용할 포트를 외부에 노출합니다.
EXPOSE 8080

# 빌드 단계에서 생성된 JAR 파일을 복사합니다.
# RUN 명령어의 결과로 생성된 파일은 build/libs/ 디렉터리에 있습니다.
COPY --from=build /app/build/libs/$JAR_FILE_NAME /app.jar

# 컨테이너 시작 시 실행될 명령어를 정의합니다.
# Spring Boot 애플리케이션을 실행합니다.
ENTRYPOINT ["java", "-jar", "/app.jar"]