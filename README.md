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
| **ts-node** | Execução direta de arquivos TypeScript em desenvolvimento |

### Como rodar

```bash
cd backend
cp .env.example .env  # configure DATABASE_URL e JWT_SECRET
npm install
npx prisma migrate dev
npm run dev
```

### Documentação da API

Com o servidor rodando, acesse `http://localhost:3000/docs` para visualizar e testar todos os endpoints via Swagger UI.

Para autenticar na interface:
1. Faça login em `POST /users/login` e copie o token retornado
2. Clique em **Authorize** (canto superior direito) e cole o token

> O `/docs` só está disponível quando `NODE_ENV` não é `production`.

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

### Como rodar

```bash
cd frontend
npm install
npm run dev
```

---

## Mobile

Localizado em [mobile/](mobile/).

| Ferramenta | Função |
|---|---|
| **Flutter** | Framework para construção da interface multiplataforma |
| **Dart** | Linguagem de programação utilizada pelo Flutter |
| **http** | Cliente HTTP para comunicação com a API do backend |
| **google_fonts** | Tipografia com a fonte Inter na interface |

### Como rodar

```bash
cd mobile
flutter pub get
flutter run
```

> Por padrão, a URL da API aponta para `http://localhost:3000`. Para alterar, defina a variável de ambiente `API_URL` ao compilar:
> ```bash
> flutter run --dart-define=API_URL=http://seu-servidor:3000
> ```
