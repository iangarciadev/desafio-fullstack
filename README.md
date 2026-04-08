# Desafio FullStack

## Resumo

Aplicação fullstack de gerenciamento de clientes e tarefas. Usuários autenticados podem cadastrar clientes e associar tarefas a eles, acompanhando o status de cada tarefa ao longo do tempo.

---

## Funcionalidades

- Autenticação de usuários com login e geração de token JWT
- Listagem e cadastro de clientes vinculados ao usuário autenticado
- Preenchimento automático de endereço via CEP (integração com ViaCEP)
- Criação de tarefas associadas a clientes
- Atualização de status das tarefas (Pendente, Em andamento, Concluída)
- Filtro de tarefas por status no frontend
- Documentação interativa da API via Swagger UI

---

## Como rodar com Docker (recomendado)

> Pré-requisito: [Docker Desktop](https://www.docker.com/products/docker-desktop) instalado e rodando.

### 1. Configurar as variáveis de ambiente

Copie o arquivo de exemplo e preencha os valores:

```bash
cp .env.docker.example .env.docker
```

### 2. Subir todos os serviços

```bash
docker compose --env-file .env.docker up --build
```

Isso vai:
1. Baixar as imagens necessárias
2. Compilar o backend (TypeScript → JavaScript)
3. Fazer o build do frontend (Vite)
4. Subir banco de dados, backend e frontend em containers
5. Rodar as migrations do banco automaticamente

### 3. Acessar o sistema

| Serviço | URL |
|---|---|
| Frontend | http://localhost |
| Documentação da API (Swagger) | http://localhost:3000/docs |

### 4. Criar um usuário e testar

1. Acesse http://localhost:3000/docs
2. Use `POST /users/register` para criar um usuário
3. Use `POST /users/login` para obter o token JWT
4. Clique em **Authorize** e cole o token para testar os demais endpoints
5. Acesse http://localhost para usar o sistema pelo frontend

---

## Como rodar localmente (sem Docker)

### Backend

```bash
cd backend
cp .env.example .env  # configure DATABASE_URL e JWT_SECRET
npm install
npx prisma migrate dev
npm run dev
```

### Frontend

```bash
cd frontend
npm install
npm run dev
```

### Mobile

```bash
cd mobile
flutter pub get
flutter run
```

> Por padrão, a URL da API aponta para `http://localhost:3000`. Para alterar, defina a variável de ambiente `API_URL` ao compilar:
> ```bash
> flutter run --dart-define=API_URL=http://seu-servidor:3000
> ```

---

## Estrutura do projeto

```
.
├── backend/        # API Node.js + TypeScript + Express
├── frontend/       # Interface Vue 3 + Vite
├── mobile/         # App Flutter
└── docker-compose.yml
```

---

## Backend

Localizado em [backend/](backend/).

| Ferramenta | Função |
|---|---|
| **Node.js + TypeScript** | Plataforma de execução e tipagem estática da API |
| **Express** | Framework HTTP para criação das rotas e middlewares |
| **Prisma** | ORM para modelagem e acesso ao banco de dados |
| **MySQL** | Banco de dados relacional onde os dados são persistidos |
| **JWT (jsonwebtoken)** | Geração e validação de tokens de autenticação |
| **bcrypt** | Hash de senhas antes de armazená-las no banco |
| **cors** | Middleware para liberar requisições cross-origin do frontend |
| **swagger-jsdoc + swagger-ui-express** | Geração e exibição da documentação interativa da API |
| **pino + pino-http** | Logging estruturado em JSON das requisições e eventos do servidor |
| **ts-node** | Execução direta de arquivos TypeScript em desenvolvimento |

### Logs estruturados

O backend utiliza [Pino](https://getpino.io) para logging estruturado em JSON. Todas as requisições HTTP são registradas automaticamente, incluindo método, rota, status code e tempo de resposta.

- **Em desenvolvimento:** logs exibidos no terminal com formatação colorida via `pino-pretty`
- **Em produção:** logs em JSON puro no stdout
- **Arquivo:** `backend/logs/app.log` (criado automaticamente, ignorado pelo git)

Exemplo de entrada no arquivo de log:
```json
{"level":30,"time":1712345679,"method":"POST","url":"/users/login","statusCode":200,"responseTime":43}
{"level":40,"time":1712345680,"path":"/clients","method":"GET","msg":"Auth rejeitado: token inválido"}
```

### Preenchimento automático de endereço

Ao cadastrar ou editar um cliente, basta informar o CEP. O frontend consulta a API pública [ViaCEP](https://viacep.com.br) e preenche automaticamente os campos de logradouro, bairro, cidade e estado.

---

## Frontend

Localizado em [frontend/](frontend/).

| Ferramenta | Função |
|---|---|
| **Vue 3** | Framework reativo para construção da interface |
| **TypeScript** | Tipagem estática nos componentes e serviços |
| **Vite** | Bundler e servidor de desenvolvimento com hot reload |
| **Vue Router** | Gerenciamento de rotas entre as páginas da aplicação |
| **Pinia** | Gerenciamento de estado global (ex: token do usuário autenticado) |
| **Axios** | Cliente HTTP para comunicação com a API do backend |
| **Prettier + ESLint + Oxlint** | Formatação e análise estática do código |

---

## Mobile

Localizado em [mobile/](mobile/).

| Ferramenta | Função |
|---|---|
| **Flutter** | Framework para construção da interface multiplataforma |
| **Dart** | Linguagem de programação utilizada pelo Flutter |
| **http** | Cliente HTTP para comunicação com a API do backend |
| **google_fonts** | Tipografia com a fonte Inter na interface |
