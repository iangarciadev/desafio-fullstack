import express from 'express'

const app = express()
app.use(express.json())

app.get('/', (req, res) => {
  res.json({ message: 'API rodando!' })
})

app.listen(3000, () => {
  console.log('Servidor na porta 3000')
})