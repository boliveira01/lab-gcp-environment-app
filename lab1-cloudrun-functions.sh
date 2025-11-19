#!/bin/bash

# Tarefa 1: Definir a região padrão
gcloud config set run/region us-central1

# Tarefa 1: Criar diretório e entrar nele
mkdir gcf_hello_world && cd $_

# Tarefa 1: Criar index.js
cat <<EOF > index.js
const functions = require('@google-cloud/functions-framework');

functions.cloudEvent('helloPubSub', cloudEvent => {
  const base64name = cloudEvent.data.message.data;

  const name = base64name
    ? Buffer.from(base64name, 'base64').toString()
    : 'World';

  console.log(\`Hello, \${name}!\`);
});
EOF

# Tarefa 1: Criar package.json
cat <<EOF > package.json
{
  "name": "gcf_hello_world",
  "version": "1.0.0",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",'
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "dependencies": {
    "@google-cloud/functions-framework": "^3.0.0"
  }
}
EOF

# Tarefa 1: Instalar dependências
npm install

# Tarefa 2: Implantar a função (Deploy)
# Nota: Usa $(gcloud config get-value project) para preencher o ID do projeto automaticamente conforme o lab exige
gcloud functions deploy nodejs-pubsub-function \
  --gen2 \
  --runtime=nodejs20 \
  --region=us-central1 \
  --source=. \
  --entry-point=helloPubSub \
  --trigger-topic cf-demo \
  --stage-bucket $(gcloud config get-value project)-bucket \
  --service-account cloudfunctionsa@$(gcloud config get-value project).iam.gserviceaccount.com \
  --allow-unauthenticated

# Tarefa 3: Testar a função
gcloud pubsub topics publish cf-demo --message="Cloud Function Gen2"

# Tarefa 4: Ver registros
gcloud functions logs read nodejs-pubsub-function --region=us-central1