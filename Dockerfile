FROM ubuntu:20.04 AS build
WORKDIR /workspace/app

RUN apt-get update && apt-get install -y wget openjdk-8-jdk curl && rm -rf /var/lib/apt/lists/*

COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY src src

RUN chmod +x mvnw && ./mvnw package -DskipTests
RUN mkdir -p target/dependency && (cd target/dependency; jar -xf ../*.jar)

FROM ubuntu:20.04
VOLUME /tmp
ARG DEPENDENCY=/workspace/app/target/dependency
RUN apt-get update && apt-get install -y openjdk-8-jdk && rm -rf /var/lib/apt/lists/*
COPY --from=build ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --from=build ${DEPENDENCY}/META-INF /app/META-INF
COPY --from=build ${DEPENDENCY}/BOOT-INF/classes /app
ENTRYPOINT ["java","-cp","app:app/lib/*","com.demo.bankapp.BankApplication"]