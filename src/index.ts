import express from 'express'
import usersRoutes from './modules/users/users.routes'
import clientsRoutes from './modules/clients/clients.routes'

const app = express()
app.use(express.json())

app.use('/users', usersRoutes)
app.use('/clients', clientsRoutes)

app.listen(3000, () => {
  console.log('Servidor na porta 3000')
})