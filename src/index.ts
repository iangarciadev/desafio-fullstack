import express from 'express'
import usersRoutes from './modules/users/users.routes'
import { authMiddleware } from './middlewares/auth.middleware'

const app = express()
app.use(express.json())

app.use('/users', usersRoutes)

app.listen(3000, () => {
  console.log('Servidor na porta 3000')
})