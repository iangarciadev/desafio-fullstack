import express from 'express'
import cors from 'cors'
import swaggerJsdoc from 'swagger-jsdoc'
import swaggerUi from 'swagger-ui-express'
import usersRoutes from './modules/users/users.routes'
import clientsRoutes from './modules/clients/clients.routes'
import tasksRoutes from './modules/tasks/tasks.routes'

const app = express()
app.use(cors())
app.use(express.json())

const swaggerOptions: swaggerJsdoc.Options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Desafio FullStack API',
      version: '1.0.0',
      description: 'API REST para gerenciamento de clientes e tarefas com autenticação JWT.',
    },
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
        },
      },
      schemas: {
        User: {
          type: 'object',
          properties: {
            id: { type: 'integer', example: 1 },
            email: { type: 'string', example: 'usuario@email.com' },
          },
        },
        Client: {
          type: 'object',
          properties: {
            id: { type: 'integer', example: 1 },
            name: { type: 'string', example: 'João Silva' },
            email: { type: 'string', example: 'joao@email.com' },
            cep: { type: 'string', example: '01310-100', nullable: true },
            logradouro: { type: 'string', example: 'Av. Paulista', nullable: true },
            numero: { type: 'string', example: '1000', nullable: true },
            complemento: { type: 'string', example: 'Apto 42', nullable: true },
            bairro: { type: 'string', example: 'Bela Vista', nullable: true },
            cidade: { type: 'string', example: 'São Paulo', nullable: true },
            estado: { type: 'string', example: 'SP', nullable: true },
            userId: { type: 'integer', example: 1 },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
        Task: {
          type: 'object',
          properties: {
            id: { type: 'integer', example: 1 },
            title: { type: 'string', example: 'Entrar em contato' },
            description: { type: 'string', example: 'Ligar para o cliente às 14h', nullable: true },
            status: {
              type: 'string',
              enum: ['PENDING', 'IN_PROGRESS', 'DONE'],
              example: 'PENDING',
            },
            clientId: { type: 'integer', example: 1 },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
      },
    },
  },
  apis: ['./src/modules/**/*.routes.ts'],
}

const swaggerSpec = swaggerJsdoc(swaggerOptions)

if (process.env.NODE_ENV !== 'production') {
  app.use('/docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec))
}

app.use('/users', usersRoutes)
app.use('/clients', clientsRoutes)
app.use('/tasks', tasksRoutes)

app.listen(3000, () => {
  console.log('Servidor na porta 3000')
  console.log('Documentação disponível em http://localhost:3000/docs')
})
