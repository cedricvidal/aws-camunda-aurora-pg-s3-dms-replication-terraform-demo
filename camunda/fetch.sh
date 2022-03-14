curl -L https://downloads.camunda.cloud/release/camunda-bpm/run/7.16/camunda-bpm-run-7.16.0.zip --output camunda-bpm-run-7.16.0.zip
mkdir -p camunda-run
unzip camunda-bpm-run-7.16.0.zip -d ./camunda-run
curl -L https://repo1.maven.org/maven2/org/postgresql/postgresql/42.3.3/postgresql-42.3.3.jar --output camunda-run/configuration/userlib/postgresql-42.3.3.jar

# Override default configuration
cp default.yml camunda-run/configuration/default.yml
